#include <stdio.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string>
#include <map>
#include <TCFoundation/TCUserDefaults.h>
#include <TCFoundation/mystring.h>
#include <LDLib/LDSnapshotTaker.h>
#include <LDLoader/LDLModel.h>
#include <TCFoundation/TCAutoreleasePool.h>
#include <TCFoundation/TCAlertManager.h>
#include <TCFoundation/TCProgressAlert.h>
#include <TCFoundation/TCLocalStrings.h>
#if defined (__APPLE__)
#include <GLUT/glut.h>
#endif
#ifndef GLAPIENTRY
#define GLAPIENTRY
#endif
#include <GL/osmesa.h>
#include <TRE/TREMainModel.h>
#include <TCFoundation/TCGLInfo.h>
#include "StudLogo.h"
#include "LDViewMessages.h"

#ifdef __USE_GNU
#include <errno.h>
#include <stdlib.h>
#endif

#ifdef VERSION_INFO
#ifdef ARCH
char LDViewVersion[] = "Version " VERSION_INFO " (" ARCH ")      ";
#else
char LDViewVersion[] = "Version " VERSION_INFO "      ";
#endif
#else
char LDViewVersion[] = "Version 4.3.0      ";
#endif

typedef std::map<std::string, std::string> StringMap;

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

std::string iniFileStatus(const char *iniPath )
{
#ifdef __USE_GNU
        errno = 0;
#endif
    FILE *iniFile = fopen(iniPath, "r+b");

    if (!iniFile)
    {
#ifdef __USE_GNU
            return formatString("%s: Could not open file %s; %s",
                                program_invocation_short_name, iniPath, strerror(errno));
#else
            return formatString("LDView: Cound not open file %s", iniPath);
#endif
    }
    // we should never get here, but if we do ...
    return NULL;
}

int setupDefaults(char *argv[])
{
    int retVal = 0;
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
            bool iniFileSet = false;

            char *rcFile = copyString(homeDir, 128);
            std::string file1Msg;

            strcat(rcFile, "/.ldviewrc");

            if (!TCUserDefaults::setIniFile(rcFile))
            {
                file1Msg = iniFileStatus(rcFile);
            }
            else
            {
                iniFileSet = true;
            }

            char *rcFile2 = NULL;
            std::string file2Msg;

            if (!iniFileSet)
            {
                rcFile2 = copyString(homeDir, 128);
                strcat(rcFile2, "/.config/LDView/ldviewrc");

                if (!TCUserDefaults::setIniFile(rcFile2))
                {
                    file2Msg = iniFileStatus(rcFile2);
                }
                else
                {
                    iniFileSet = true;
                }
            }

            if (!iniFileSet)
            {
                printf("Could not set user INI file Returned messages:\n"
                       " - %s\n - %s\n", file1Msg.c_str(), file2Msg.c_str());
                retVal = 1;
            }
            delete rcFile;
            delete rcFile2;
        }
        else
        {
            printf("HOME environment variable not defined: cannot use "
                "~/.ldviewrc.\n");
            retVal = 1;
		}
	}
    setDebugLevel(TCUserDefaults::longForKey("DebugLevel", 0, false));
    return retVal;
}

void *setupContext(OSMesaContext &ctx)
{
	void *buffer = NULL;
	int width = TCUserDefaults::longForKey("TileWidth", 1024, false);
	int height = TCUserDefaults::longForKey("TileHeight", 1024, false);
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
	if (!OSMesaMakeCurrent(ctx, buffer, GL_UNSIGNED_BYTE, width, height))
	{
		printf("Error attaching buffer to context.\n");
		free(buffer);
		buffer = NULL;
	}
	return buffer;
}

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
	int count;
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
		for (int i = 1; i + 1 < count && ok; ++i)
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

int main(int argc, char *argv[])
{
    printf("\nLDView CUI (Offscreen Renderer) %s\n", LDViewVersion);
    printf("==========================\n");

	void *buffer;
	OSMesaContext ctx;
	int stringTableSize = sizeof(LDViewMessages_bytes);
	char *stringTable = new char[sizeof(LDViewMessages_bytes) + 1];
    bool defaultsKO = false;

	memcpy(stringTable, LDViewMessages_bytes, stringTableSize);
	stringTable[stringTableSize] = 0;
	TCLocalStrings::setStringTable(stringTable);
  if (setupDefaults(argv) != 0)
  {
      if (TCUserDefaults::boolForKey("Info"))
      {
          defaultsKO = true;
      }
      else
      {
          return 1;
      }
  }
	if ((buffer = setupContext(ctx)) != NULL)
	{
		//ProgressHandler *progressHandler = new ProgressHandler;

        if (TCUserDefaults::boolForKey("Info"))
        {
            printf("Arguments = ");
            int cnt;
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

            //get OpenGL info
            glInfo glinfo;
            glinfo.getInfo();
            glinfo.printSelf();
        }
        if (defaultsKO)
        {
            return 1;
        }
		TREMainModel::setStudTextureData(StudLogo_bytes,
			sizeof(StudLogo_bytes));
		LDLModel::setFileCaseCallback(fileCaseCallback);
		LDSnapshotTaker::doCommandLine();
		OSMesaDestroyContext(ctx);
		free(buffer);

		//TCObject::release(progressHandler);
	}
	TCAutoreleasePool::processReleases();
	return 0;
}
