#include <winsock2.h>
#include <windows.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string>
#include <map>
#ifdef __USE_GNU
#include <errno.h>
#include <stdlib.h>
#endif

#include <TCFoundation/TCUserDefaults.h>
#include <TCFoundation/TCAutoreleasePool.h>
#include <TCFoundation/TCAlertManager.h>
#include <TCFoundation/TCLocalStrings.h>
#include <TCFoundation/mystring.h>

#include <LDLoader/LDLModel.h>
#include <LDLib/LDUserDefaultsKeys.h>
#include <TRE/TREMainModel.h>
#include <CUI/CUIWindow.h>

#include "LDViewCUIModelLoader.h"
#include "WinWebClientPlugin.h"

#include "StudLogo.h"
#include "LDViewCUIMessages.h"

#ifdef VERSION_INFO
#ifdef ARCH
char LDViewVersion[] = VERSION_INFO " (" ARCH ")	  ";
#else
char LDViewVersion[] = VERSION_INFO "	   ";
#endif
#else
char LDViewVersion[] = "4.6.0	   ";
#endif

typedef std::map<std::string, std::string> StringMap;

static bool debugToFile = false;

void createConsole(void)
{
	if (AllocConsole())
	{
		COORD size = {80, 1000};
		SMALL_RECT rect = {0, 0, 79, 24};

		SECURITY_ATTRIBUTES securityAttributes;
		securityAttributes.nLength = sizeof(SECURITY_ATTRIBUTES);
		securityAttributes.lpSecurityDescriptor = NULL;
		securityAttributes.bInheritHandle = TRUE;

		HANDLE hStdOut;
		hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
		SetConsoleScreenBufferSize(hStdOut, size);
		SetConsoleWindowInfo(hStdOut, TRUE, &rect);
		SetConsoleActiveScreenBuffer(hStdOut);

#pragma warning(push)
#pragma warning(disable: 6031)
		freopen("CONOUT$", "w", stdout);
		freopen("CONIN$", "r", stdin);
#pragma warning(pop)
	}
}

void debugOut(char *fmt, ...)
{
	if (!debugToFile)
	{
		return;
	}
	static const char* userProfile = getenv("USERPROFILE");
	std::string debugPath = "C:\\LDViewDebug.txt";
	if (userProfile != NULL)
	{
		debugPath = std::string(userProfile) + "\\LDViewDebug.txt";
	}
	FILE* debugFile = ucfopen(debugPath.c_str(), "a+");

	if (debugFile)
	{
		va_list marker;
#ifdef __MINGW64__
		const char* format = "%Y-%m-%d %H:%M:%S";
#else
		const char* format = "%F %T";
#endif
		std::time_t t = std::time(nullptr);
		char mbstr[100];
		if (std::strftime(mbstr, sizeof(mbstr), format, std::localtime(&t)))
		{
			fprintf(debugFile, "%s: ", mbstr);
		}
		va_start(marker, fmt);
		vfprintf(debugFile, fmt, marker);
		va_end(marker);
		fclose(debugFile);
	}
}

static void loadLanguageModule(void)
{
	// This function is something of a hack.  We want to force the language
	// module to load with certain pre-conditions.	The first is that prior to
	// going into this function, the app name was set to LDView.  The next is
	// that we want to change into the LDView directory, so that the
	// LoadLibrary call will find language modules in that directory.
	UCCHAR originalPath[1024];
	DWORD maxPath = COUNT_OF(originalPath);
	DWORD dirResult = GetCurrentDirectoryW(maxPath, originalPath);
	bool dirChange = false;

	if (dirResult > 0 && dirResult <= maxPath)
	{
		UCSTR installPath =
			TCUserDefaults::stringForKeyUC(INSTALL_PATH_4_1_KEY, NULL, false);

		if (installPath)
		{
			SetCurrentDirectoryW(installPath);
			delete[] installPath;
			dirChange = true;
		}
	}
	// The following forces CUIWindow to load (and cache) the language module.
	CUIWindow::getLanguageModule();
	if (dirChange)
	{
		SetCurrentDirectoryW(originalPath);
	}
}

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

int setupDefaults(char *argv[])
{
	int retValue = 0;
	bool iniFileSet = false;
	TCUserDefaults::setCommandLine(argv);
	WinWebClientPlugin::registerPlugin();
	debugToFile = TCUserDefaults::boolForKey("DebugToFile", false, false);
	std::string haveStdOut =
		TCUserDefaults::commandLineStringForKey("HaveStdOut");
	if (!haveStdOut.empty())
	{
		if (std::strtol(haveStdOut.c_str(), NULL, 10) != 0)
		{
			runningWithConsole();
		}
	}

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

	// Check if we have an IniFile at the usual locations...
	if (!iniFileSet)
	{
			// Check home directory path
			char *homeDir = getenv("USERPROFILE");
#ifdef __MINGW64__
			if (homeDir == NULL)
				homeDir = getenv("HOME");
#endif
		char *rcFilename = NULL;

		if (homeDir)
		{
			char *ldviewrc = copyString("\\ldview.ini");

			rcFilename = copyString(homeDir, 128);

			strncat(rcFilename, ldviewrc, strlen(ldviewrc)+1);

			iniFileSet = TCUserDefaults::setIniFile(rcFilename);
			if (!iniFileSet)
			{
				printf("Error setting INI File to %s\n", rcFilename);

				rcFilename = copyString(homeDir, 128);

				ldviewrc = copyString("\\.config\\LDView\\ldview.ini");

				strncat(rcFilename, ldviewrc, strlen(ldviewrc)+1);

				iniFileSet = TCUserDefaults::setIniFile(rcFilename);
			}
		}

		// Try to force the default ini at the executable root
		if (!iniFileSet)
		{
			retValue = 1;
			printf("Error setting INI File to %s\n", rcFilename);
			iniFileSet = TCUserDefaults::setIniFile("ldview.ini");
			if (iniFileSet)
			{
				printf("Using default INI file ldview.ini.");
				retValue = 0;
			}
		}

		if (!iniFileSet && !TCUserDefaults::longForKey("IniFailureShown", 0, 0))
		{
			UCCHAR message[2048];
			ucstring iniPath;
			utf8toucstring(iniPath, TCUserDefaults::getIniPath());
			sucprintf(message, COUNT_OF(message),
					  TCLocalStrings::get(_UC("IniFailure")), iniPath.c_str());
			printf("%ls\n", message);
			TCUserDefaults::setLongForKey(1, "IniFailureShown", false);
		}
	}

	const char *applicationName = "Travis Cobbs/LDView - LPub3D Edition";
	TCUserDefaults::setAppName(applicationName);

	// The language module needs to be loaded using LDView as the app name.	 So
	// if we're running in screensaver mode, we'll take care of changing our
	// app name after that is done.
	loadLanguageModule();

#ifdef _DEBUG
	setDebugLevel((int)TCUserDefaults::longForKey(PREFERENCE_SET_KEY, 1, false));
#endif // _DEBUG

	const char *sessionName = TCUserDefaults::getSavedSessionNameFromKey(PREFERENCE_SET_KEY);
	if (sessionName && sessionName[0])
	{
		TCUserDefaults::setSessionName(sessionName, NULL, false);
	}
	delete sessionName;

	return retValue;
}

int main(int argc, char *argv[])
{
	printf("\nLDView - LPub3D Edition CUI (Offscreen Renderer) Version %s\n", LDViewVersion);
	printf("=========================================\n");
	bool defaultsOK = true;
	int retValue = 0;

	int stringTableSize = sizeof(LDViewCUIMessages_bytes);
	char *stringTable = new char[sizeof(LDViewCUIMessages_bytes) + 1];

	memcpy(stringTable, LDViewCUIMessages_bytes, stringTableSize);
	stringTable[stringTableSize] = 0;
	TCLocalStrings::setStringTable(stringTable);

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
	}

#ifdef _DEBUG
	int _debugFlag = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
	_debugFlag |= _CRTDBG_LEAK_CHECK_DF;
	_CrtSetDbgFlag(_debugFlag);
	_CrtSetReportMode(_CRT_WARN, _CRTDBG_MODE_DEBUG);
	if (!haveConsole())
	{
		createConsole();
	}
#endif // _DEBUG

	if (defaultsOK)
	{
		TREMainModel::setStudTextureData(StudLogo_bytes,
			sizeof(StudLogo_bytes));
		LDViewCUIModelLoader* modelLoader = new LDViewCUIModelLoader(
			CUIWindow::getLanguageModule(), printInfo);
		modelLoader->release();
	}

	return retValue;
}
