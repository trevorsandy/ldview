#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <map>
#include <TCFoundation/TCUserDefaults.h>
#include <TCFoundation/mystring.h>
#include <LDLib/LDSnapshotTaker.h>
#include <LDLib/LDUserDefaultsKeys.h>
#include <LDLoader/LDLModel.h>
#include <TCFoundation/TCAutoreleasePool.h>
#include <TCFoundation/TCAlertManager.h>
#include <TCFoundation/TCProgressAlert.h>
#include <TCFoundation/TCLocalStrings.h>
// LPub3D Mod - Main includes
#if defined (__APPLE__)
#include <GLUT/glut.h>
#else  // !defined (__APPLE__)
#ifdef EGL
#include <sstream>
#include <stdexcept>
#include <EGL/egl.h>
#include <GL/gl.h>
#endif // EGL
#endif // defined (__APPLE__)
#ifndef GLAPIENTRY
#define GLAPIENTRY
#endif // GLAPIENTRY
#ifndef __USE_EGL
#include <GL/osmesa.h>
#endif // __USE_EGL
// LPub3D Mod End
#include <TRE/TREMainModel.h>
// LPub3D Mod - Main includes
#include "GLInfo.h"
// LPub3D Mod End
#include "StudLogo.h"
#include "LDViewMessages.h"
// LPub3D Mod - Main includes
#ifdef __USE_GNU
#include <errno.h>
#include <stdlib.h>
#endif // __USE_GNU
// LPub3D Mod End
// LPub3D Mod - version info
#ifdef VERSION_INFO
#ifdef ARCH
char LDViewVersion[] = VERSION_INFO " (" ARCH ")      ";
#else
char LDViewVersion[] = VERSION_INFO "      ";
#endif
#else
char LDViewVersion[] = "4.6.1      ";
#endif
// LPub3D Mod End

typedef std::map<std::string, std::string> StringMap;
static int TileWidth = 1024, TileHeight = 1024;

#define DEPTH_BPP 24
// Note: buffer contains only color buffer, not depth and stencil.
#define BYTES_PER_PIXEL 4

class ProgressHandler: public TCObject
{
public:
	ProgressHandler(void)
	{
		TCAlertManager::registerHandler(TCProgressAlert::alertClass(), this,
			(TCAlertCallback)&ProgressHandler::alertCallback);
	}
protected:
	~ProgressHandler(void)
	{
	}
	void dealloc(void)
	{
		TCAlertManager::unregisterHandler(this);
		TCObject::dealloc();
	}
	void alertCallback(TCProgressAlert *progress)
	{
		if (progress->getMessage() && strlen(progress->getMessage()))
		{
			printf("%s: %f%%\n", progress->getMessage(),
				progress->getProgress() * 100.0f);
		}
	}
};

bool dirExists(const std::string &path)
{
	struct stat buf;
	if (stat(path.c_str(), &buf) != 0)
	{
		return false;
	}
	return S_ISDIR(buf.st_mode);
}

bool fileOrDirExists(const std::string &path)
{
	struct stat buf;
	if (stat(path.c_str(), &buf) != 0)
	{
		return false;
	}
	return S_ISREG(buf.st_mode) || S_ISDIR(buf.st_mode);
}

bool findDirEntry(std::string &path)
{
	size_t lastSlash = path.rfind('/');
	if (lastSlash >= path.size())
	{
		return false;
	}
	std::string dirName = path.substr(0, lastSlash);
	std::string lowerFilename = lowerCaseString(path.substr(lastSlash + 1));
	DIR *dir = opendir(dirName.c_str());
	if (dir == NULL)
	{
		return false;
	}
	bool found = false;
	while (!found)
	{
		struct dirent *entry = readdir(dir);
		if (entry == NULL)
		{
			break;
		}
		std::string name = lowerCaseString(entry->d_name);
		if (name == lowerFilename)
		{
			path = dirName + '/' + entry->d_name;
			found = true;
		}
	}
	closedir(dir);
	return found;
}

bool fileCaseCallback(char *filename)
{
	StringMap s_pathMap;
	size_t count;
	char **components = componentsSeparatedByString(filename, "/", count);
	std::string lowerFilename = lowerCaseString(filename);

	StringMap::iterator it = s_pathMap.find(lowerFilename);
	if (it != s_pathMap.end())
	{
		strcpy(filename, it->second.c_str());
		return true;
	}
	if (count > 1)
	{
		bool ok = true;
		std::string builtPath = "/";
		for (size_t i = 1; i + 1 < count && ok; ++i)
		{
			builtPath += components[i];

			it = s_pathMap.find(builtPath);
			if (it != s_pathMap.end())
			{
				// Do nothing
			}
			else if (dirExists(builtPath))
			{
				s_pathMap[lowerCaseString(builtPath)] = builtPath;
			}
			else if (findDirEntry(builtPath))
			{
				s_pathMap[lowerCaseString(builtPath)] = builtPath;
				if (!dirExists(builtPath))
				{
					ok = false;
				}
			}
			else
			{
				ok = false;
			}
			if (ok)
			{
				builtPath += '/';
			}
		}
		if (ok)
		{
			builtPath += components[count - 1];
			if (findDirEntry(builtPath))
			{
				s_pathMap[lowerCaseString(builtPath)] = builtPath;
				ok = fileOrDirExists(builtPath);
			}
			else
			{
				ok = false;
			}
		}
		if (ok)
		{
			strcpy(filename, builtPath.c_str());
		}
		deleteStringArray(components, count);
		return ok;
	}
	return false;
}

// LPub3D Mod - process ini file
std::string iniFileStatus(const char *iniPath )
{
	FILE *iniFile = ucfopen(iniPath, "r+b");
	if (!iniFile)
	{
#ifdef __USE_GNU
		errno = 0;
		return formatString("%s: Could not open file %s; %s",
							program_invocation_short_name, iniPath, strerror(errno));
#else
		return formatString("LDView: Cound not open file %s", iniPath);
#endif // !__USE_GNU
	}
	// we should never get here, but if we do ...
	return std::string();
}
// LPub3D Mod End

int setupDefaults(char *argv[])
{
	int retValue = 0;
	bool iniFileSet = false;
	TCUserDefaults::setCommandLine(argv);
	// First, check if an IniFile is specified on command line...
	std::string iniFile = TCUserDefaults::commandLineStringForKey("IniFile");
	if (iniFile.size() > 0)
	{
		iniFileSet = TCUserDefaults::isIniFileSet();
		if (!iniFileSet)
		{
			std::string fileMsg = iniFileStatus(iniFile.c_str());
			printf("Could not set command line INI file. Returned message:\n"
				   " - %s\n - ldview: Checking for user INI files...\n", fileMsg.c_str());
		}
	}

	if (!iniFileSet)
	{
		char *homeDir = getenv("HOME");
#ifdef WIN32
		if (homeDir == NULL)
			homeDir = getenv("USERPROFILE");
		char *ldviewrc = copyString("\\ldview.ini");
#else
		char *ldviewrc = copyString("/.ldviewrc");
#endif
		char *rcFilename = NULL;

		if (homeDir)
		{
			rcFilename = copyString(homeDir, 128);

			strncat(rcFilename, ldviewrc, strlen(ldviewrc)+1);

			char *rcFilename2 = copyString(homeDir, 128);

#ifdef WIN32
			ldviewrc = copyString("\\.config\\LDView\\ldview.ini");
#else
			ldviewrc = copyString("/.config/LDView/ldviewrc");
#endif

			strncat(rcFilename2, ldviewrc, strlen(ldviewrc)+1);

			if (!TCUserDefaults::setIniFile(rcFilename) &&
				!TCUserDefaults::setIniFile(rcFilename2))
			{
				printf("Error setting INI File to %s or %s\n", rcFilename,
					rcFilename2);
				retValue = 1;
			} else iniFileSet = true;
		}
		else
		{
			printf("HOME environment variable not defined: cannot use "
				"~/.ldviewrc.\n");
			retValue = 1;
		}

		// Try to force the default ini at the executable root
		if (!iniFileSet)
		{
			retValue = 1;
			if (rcFilename)
				printf("Error setting INI File to %s\n", rcFilename);
#ifdef WIN32
			ldviewrc = copyString("ldview.ini");
#else
			ldviewrc = copyString("ldviewrc");
#endif
			rcFilename = copyString(ldviewrc, 32);

			iniFileSet = TCUserDefaults::setIniFile(ldviewrc);
		}

		if(iniFileSet)
		{
			retValue = 0;
			if (TCUserDefaults::boolForKey("Info"))
				printf("Using IniFile %s\n", rcFilename);
		}
	}

#ifdef _DEBUG
	setDebugLevel(TCUserDefaults::longForKey(PREFERENCE_SET_KEY, 0, false));
#endif // _DEBUG

	return retValue;
}

void assertOpenGLError(const std::string& msg, bool throwErr = false)
{
	GLenum error = glGetError();

	if (error != GL_NO_ERROR)
	{
		std::stringstream ss;
		ss << "OpenGL error - 0x" << std::hex << error << " at " << msg;
		if (throwErr)
			throw std::runtime_error(ss.str());
		else
			printf("%s\n", ss.str().c_str());
	}
}

#ifdef EGL
void assertEGLError(const std::string& msg, bool throwErr = false)
{
	EGLint error = eglGetError();

	if (error != EGL_SUCCESS)
	{
		std::stringstream ss;
		ss << "EGL error - 0x" << std::hex << error << " at " << msg;
		switch(error)
		{
		case EGL_BAD_ACCESS            : ss << " (EGL_BAD_ACCESS)"; break;
		case EGL_BAD_ALLOC             : ss << " (EGL_BAD_ALLOC)"; break;
		case EGL_BAD_ATTRIBUTE         : ss << " (EGL_BAD_ATTRIBUTE)"; break;
		case EGL_BAD_CONFIG            : ss << " (EGL_BAD_CONFIG)"; break;
		case EGL_BAD_CONTEXT           : ss << " (EGL_BAD_CONTEXT)"; break;
		case EGL_BAD_CURRENT_SURFACE   : ss << " (EGL_BAD_CURRENT_SURFACE)"; break;
		case EGL_BAD_DISPLAY           : ss << " (EGL_BAD_DISPLAY)"; break;
		case EGL_BAD_MATCH             : ss << " (EGL_BAD_MATCH)"; break;
		case EGL_BAD_NATIVE_PIXMAP     : ss << " (EGL_BAD_NATIVE_PIXMAP)"; break;
		case EGL_BAD_NATIVE_WINDOW     : ss << " (EGL_BAD_NATIVE_WINDOW)"; break;
		case EGL_BAD_PARAMETER         : ss << " (EGL_BAD_PARAMETER)"; break;
		case EGL_BAD_SURFACE           : ss << " (EGL_BAD_SURFACE)"; break;
		case EGL_NON_CONFORMANT_CONFIG : ss << " (EGL_NON_CONFORMANT_CONFIG)"; break;
		case EGL_NOT_INITIALIZED       : ss << " (EGL_NOT_INITIALIZED)"; break;
		}

		if (throwErr)
			throw std::runtime_error(ss.str());
		else
			printf("%s\n", ss.str().c_str());
	}
}

bool setupEGL(EGLDisplay& display, EGLContext& context, EGLSurface& surface, EGLConfig& config)
{
	int width = TCUserDefaults::longForKey("TileWidth", TileWidth, false);
	int height = TCUserDefaults::longForKey("TileHeight", TileHeight, false);
	EGLint configNum = 0, eglMajor = 0, eglMinor = 0;
	const EGLint configAttribs[] = {
		EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
		EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT,
		EGL_COLOR_BUFFER_TYPE, EGL_RGB_BUFFER,
		EGL_RED_SIZE, 8,
		EGL_GREEN_SIZE, 8,
		EGL_BLUE_SIZE, 8,
		EGL_ALPHA_SIZE, 8,
		EGL_DEPTH_SIZE, 24,
		EGL_STENCIL_SIZE, 8,
		EGL_BUFFER_SIZE, 24,
		EGL_NONE,
	};
	const EGLint surfaceAttribs[] = {
		EGL_WIDTH, width,
		EGL_HEIGHT, height,
		EGL_NONE,
	};
	const EGLint contextAttribs[] = {
		EGL_NONE,
	};

	eglBindAPI(EGL_OPENGL_ES_API);
	assertEGLError("eglBindAPI", true);

	display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
	assertEGLError("eglGetDisplay");
	if (display == EGL_NO_DISPLAY)
	{
		printf("EGL error - create a default display failed.\n");
		return false;
	}

	EGLBoolean result = eglInitialize(display, &eglMajor, &eglMinor);
	assertEGLError("eglInitialize");
	if (!result)
	{
		printf("EGL error - initialize the default display failed.\n");
		return false;
	}
	//printf("Debug: EGL Version: v%d.%d\n", eglMajor, eglMinor);

	/*
	// Debug: Get number of all configs, having gotten display from EGL
	GLInfo glinfo;
	glinfo.printEGLConfigs(display);
	//*/

	result = eglChooseConfig(display, configAttribs, &config, 1, &configNum);
	assertEGLError("eglChooseConfig");
	if (!result)
	{
		printf("EGL error - get a config for specified attributes failed.\n");
		return false;
	}
	//printf("Debug: EGL chosen configuration %d\n", configNum);

	surface = eglCreatePbufferSurface(display, config, surfaceAttribs);
	assertEGLError("eglCreatePbufferSurface");
	if (surface == EGL_NO_SURFACE)
	{
		printf("EGL error - create a pixel buffer surface failed.\n");
		return false;
	}

	context = eglCreateContext(display, config, EGL_NO_CONTEXT, contextAttribs);
	assertEGLError("eglCreateContext");
	if (context == EGL_NO_CONTEXT)
	{
		printf("EGL error - create a display context failed.\n");
		return false;
	}

	result = eglMakeCurrent(display, surface, surface, context);
	assertEGLError("eglMakeCurrent");
	if (!result)
	{
		printf("EGL error - make display, surface and context current failed.\n");
		return false;
	}
	else
	{
		//glViewport(0, 0, width, height);
		//assertOpenGLError("glViewport");

		GLint viewport[4] = {0};
		glGetIntegerv(GL_VIEWPORT, viewport);
		assertOpenGLError("glGetIntegerv");
		if (viewport[2] != width || viewport[3] != height)
		{
			printf("EGL error - GL_VIEWPORT: %d, %d, %d, %d - initialize GL Viewport failed.\n",
				  (int)viewport[0], (int)viewport[1], (int)viewport[2], (int)viewport[3]);
			return false;
		}
	}

	return true;
}
#endif

#ifndef __USE_EGL
void *setupOSMesaContext(OSMesaContext &ctx)
{
	void *buffer = NULL;
	int width = TCUserDefaults::longForKey("TileWidth", TileWidth, false);
	int height = TCUserDefaults::longForKey("TileHeight", TileHeight, false);
	int tileSize = TCUserDefaults::longForKey("TileSize", -1, false);

	if (tileSize > 0)
	{
		width = height = tileSize;
	}
	ctx = OSMesaCreateContextExt(OSMESA_RGBA, DEPTH_BPP, 8, 0, NULL);
	if (!ctx)
	{
		printf("Error creating OSMesa context.\n");
		return NULL;
	}
	buffer = malloc(width * height * BYTES_PER_PIXEL * sizeof(GLubyte));
	if (OSMesaMakeCurrent(ctx, buffer, GL_UNSIGNED_BYTE, width, height))
	{
		GLint viewport[4] = {0};
		glGetIntegerv(GL_VIEWPORT, viewport);
		assertOpenGLError("glGetIntegerv", true);
		if (viewport[2] != width || viewport[3] != height)
		{
			printf("OSMesa not working! GL_VIEWPORT: %d, %d, %d, %d\n",
				  (int)viewport[0], (int)viewport[1], (int)viewport[2], (int)viewport[3]);
			free(buffer);
			buffer = NULL;
		}
	}
	else
	{
		printf("Error attaching buffer to context.\n");
		free(buffer);
		buffer = NULL;
	}
	return buffer;
}
#endif

int main(int argc, char *argv[])
{
	// LPub3D Mod - print header and arguments
	printf("\nLDView - LPub3D Edition CUI (Offscreen Renderer) Version %s\n", LDViewVersion);
	printf("=========================================\n");
	bool defaultsOK = true;
	int retValue = 0;
	// LPub3D Mod End
	void *osmesaBuffer = NULL;
#ifndef __USE_EGL
	OSMesaContext ctx;
#endif
	int stringTableSize = sizeof(LDViewMessages_bytes);
	char *stringTable = new char[sizeof(LDViewMessages_bytes) + 1];
	bool useEGL = false;

#ifdef EGL
	EGLConfig  config  = 0;
	EGLDisplay display = NULL;
	EGLContext context = NULL;
	EGLSurface surface = NULL;
#endif

	memcpy(stringTable, LDViewMessages_bytes, stringTableSize);
	stringTable[stringTableSize] = 0;
	TCLocalStrings::setStringTable(stringTable);

	// LPub3D Mod - setup defaults, EGL and OSMesa
	if (setupDefaults(argv) != 0)
	{
		retValue = 1;
		if (TCUserDefaults::boolForKey("Info") || TCUserDefaults::boolForKey("Arguments"))
		{
			defaultsOK = false;
		}
		else
		{
			return retValue;
		}
	}

#ifdef EGL
	bool ignoreEGL = TCUserDefaults::boolForKey(IGNORE_EGL_KEY, false, false);
	if (!ignoreEGL)
	{
		try
		{
			useEGL = setupEGL(display, context, surface, config);
		}
		catch (std::runtime_error const& e)
		{
			if (TCUserDefaults::boolForKey("Info"))
				printf("%s\n", e.what());
		}
		catch (...)
		{
		}
	}
#endif

#ifndef __USE_EGL
	if (!useEGL)
		osmesaBuffer = setupOSMesaContext(ctx);
#endif

	if (useEGL || osmesaBuffer)
	{
		//ProgressHandler *progressHandler = new ProgressHandler;
		// LPub3D Mod - print Arguments and/or OpenGL Info
		bool printInfo = TCUserDefaults::boolForKey("Info");
		bool printArguments = TCUserDefaults::boolForKey("Arguments");
		if (printInfo || printArguments)
		{
			printf("Arguments = ");
			int cnt = 0;
			int ppl = 3;
			for (int i = 0; i < argc; i++)
			{
				cnt = i+1;
				printf("%s ", argv[i]);
				if (cnt % ppl == 0 )
					printf("\n");
			}
			if (cnt <= ppl)
				printf("\n");
			printf("\n");

			if (printInfo)
			{
				//get OpenGL info
				GLInfo glinfo;
#ifdef EGL
				if (useEGL)
					glinfo.printEGLInfo(display, config);
				else
#endif
					glinfo.printGLInfo();
			}
		}
		if (defaultsOK)
		{
			TREMainModel::setStudTextureData(StudLogo_bytes,
				sizeof(StudLogo_bytes));
			LDLModel::setFileCaseCallback(fileCaseCallback);
			LDSnapshotTaker::doCommandLine();
		}
		// LPub3D Mod End

#ifdef EGL
		if (display != NULL)
		{
			eglDestroyContext(display, context);
			eglDestroySurface(display, surface);
			eglTerminate(display);
		}
#endif
#ifndef __USE_EGL
		if (!useEGL)
		{
			OSMesaDestroyContext(ctx);
			free(osmesaBuffer);
		}
#endif
		//TCObject::release(progressHandler);
	}

	TCAutoreleasePool::processReleases();

	return retValue;
}
