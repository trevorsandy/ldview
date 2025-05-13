#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <map>
#include <GL/gl.h>
#if defined (__APPLE__)
#include <GLUT/glut.h>
#else  // defined (__APPLE__)
#include <sstream>
#include <stdexcept>
#endif // defined (__APPLE__)
#include <TCFoundation/TCUserDefaults.h>
#include <TCFoundation/mystring.h>
#include <LDLib/LDSnapshotTaker.h>
#include <LDLib/LDUserDefaultsKeys.h>
#include <LDLoader/LDLModel.h>
#include <TCFoundation/TCAutoreleasePool.h>
#include <TCFoundation/TCAlertManager.h>
#include <TCFoundation/TCProgressAlert.h>
#include <TCFoundation/TCLocalStrings.h>
#include <GL/osmesa.h>
//#define GL_GLEXT_PROTOTYPES
#include <GL/glext.h>
#include <TRE/TREMainModel.h>
#include "StudLogo.h"
#include "LDViewMessages.h"
#include "GLInfo.h"
#ifdef __USE_GNU
#include <errno.h>
#include <stdlib.h>
#endif // !__USE_GNU
#ifndef GLAPIENTRY
#define GLAPIENTRY
#endif
// LPub3D Mod - version info
#ifdef VERSION_INFO
#ifdef ARCH
char LDViewVersion[] = VERSION_INFO " (" ARCH ")      ";
#else
char LDViewVersion[] = VERSION_INFO "      ";
#endif
#else
char LDViewVersion[] = "4.5.0      ";
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
	TCUserDefaults::setCommandLine(argv);
	// IniFile can be specified on the command line; if so, don't load a
	// different one.
	if (!TCUserDefaults::isIniFileSet())
	{
		// Check if IniFile specified on command line ...
		std::string iniFile = TCUserDefaults::commandLineStringForKey("IniFile");
		if (iniFile.size() > 0 )
		{
			std::string fileMsg = iniFileStatus(iniFile.c_str());
			printf("Could not set command line INI file. Returned message:\n"
				   " - %s\n - ldview: Checking for user INI files...\n", fileMsg.c_str());
		}

		char *homeDir = getenv("HOME");

		if (homeDir)
		{
			char *ldviewrc = copyString("/.ldviewrc");

			char *rcFilename = copyString(homeDir, 128);

			strncat(rcFilename, ldviewrc, strlen(ldviewrc)+1);

			char *rcFilename2 = copyString(homeDir, 128);

			ldviewrc = copyString("/.config/LDView/ldviewrc");

			strncat(rcFilename2, ldviewrc, strlen(ldviewrc)+1);

			if (!TCUserDefaults::setIniFile(rcFilename) &&
				!TCUserDefaults::setIniFile(rcFilename2))
			{
				printf("Error setting INI File to %s or %s\n", rcFilename,
					rcFilename2);
				retValue = 1;
			}
		}
		else
		{
			printf("HOME environment variable not defined: cannot use "
				"~/.ldviewrc.\n");
			retValue = 1;
		}
	}

#ifdef _DEBUG
	setDebugLevel(TCUserDefaults::longForKey(PREFERENCE_SET_KEY, 0, false));
#endif // _DEBUG

	return retValue;
}

void assertOpenGLError(const std::string& msg)
{
	GLenum error = glGetError();

	if (error != GL_NO_ERROR)
	{
		std::stringstream ss;
		ss << "OpenGL error - 0x" << std::hex << error << " at " << msg;
		throw std::runtime_error(ss.str());
	}
}

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
		assertOpenGLError("glGetIntegerv");
		if (viewport[2] != width || viewport[3] != height)
		{
			printf("OSMesa not working!\n");
			printf("GL_VIEWPORT: %d, %d, %d, %d\n", (int)viewport[0],
				(int)viewport[1], (int)viewport[2], (int)viewport[3]);
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

int main(int argc, char *argv[])
{
	// LPub3D Mod - print header and arguments
	printf("\nLDView - LPub3D Edition CUI (Offscreen Renderer) Version %s\n", LDViewVersion);
	printf("=========================================\n");
	bool defaultsOK = true;
	int retValue = 0;
	// LPub3D Mod End
	void *osmesaBuffer = NULL;
	OSMesaContext ctx;
	int stringTableSize = sizeof(LDViewMessages_bytes);
	char *stringTable = new char[sizeof(LDViewMessages_bytes) + 1];

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

	if (setupOSMesaContext(ctx) != 0)
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

		if (osmesaBuffer)
		{
			OSMesaDestroyContext(ctx);
			free(osmesaBuffer);
		}
		//TCObject::release(progressHandler);
	}

	TCAutoreleasePool::processReleases();

	return retValue;
}
