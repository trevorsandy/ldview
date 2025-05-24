#include <QtGlobal>

#ifdef Q_OS_WIN
#include <winsock2.h>
#include <windows.h>
#endif

#if QT_VERSION >= QT_VERSION_CHECK(6,0,0)
#include <QWidget>
#include <QtOpenGL>
#else
#include <QApplication>
#include <QTextCodec>
#include <qgl.h>
#endif

#include <QLocale>
#include <QDebug>

#include <TCFoundation/TCUserDefaults.h>
#include <TCFoundation/TCLocalStrings.h>
#include <TCFoundation/TCAutoreleasePool.h>
#include <TCFoundation/TCAlertManager.h>
#include <TCFoundation/TCLocalStrings.h>
#include <TCFoundation/mystring.h>

#include <LDLib/LDUserDefaultsKeys.h>
#include <LDLoader/LDLModel.h>
#include <TRE/TREMainModel.h>
#include <TRE/TREGLExtensions.h>

#include "SnapshotTaker.h"
#include "QtWebClientPlugin.h"

#include "StudLogo.h"
#include "LDViewMessages.h"

#include <string.h>
#include <stdio.h>

#ifdef __USE_GNU
#include <errno.h>
#include <stdlib.h>
#endif

#ifdef VERSION_INFO
#ifdef ARCH
char LDViewVersion[] = VERSION_INFO " (" ARCH ")      ";
#else
char LDViewVersion[] = VERSION_INFO "      ";
#endif
#else
char LDViewVersion[] = "4.6.1      ";
#endif

static bool debugToFile = false;

#ifdef __linux__
#include <signal.h>
#include <sys/resource.h>

#include <QThread>
class KillThread : public QThread
{
public:
	virtual void run()
	{
		// The kill sometimes results in a core dump.  Make sure that doesn't
		// happen by setting the core dump limit to 0.
		struct rlimit limit;
		getrlimit(RLIMIT_CORE, &limit);
		limit.rlim_cur = 0;
		setrlimit(RLIMIT_CORE, &limit);
		// There's no point forcing the user to wait 2 seconds if it is known
		// for a fact that the shutdown is going to fail, so if they manually
		// set the AlwaysForceKill key, then just kill without the 2-second
		// wait.
		if (!TCUserDefaults::boolForKey("AlwaysForceKill", false, false))
		{
			sleep(2);
			// LDView fails to exit when running with the ATI video driver on
			// Linux. If we get here before the program has already killed off
			// this thread due to exiting, then force a kill.  It's very
			// unlikely that atexit() shutdown processing will take 2 full
			// seconds, so if we do get here, it's a pretty safe bet that the
			// program is locked up.
		}
		kill(getpid(), SIGQUIT);
	}
};
#endif // __linux__

void debugOut(char *fmt, ...)
{
	if (!debugToFile)
	{
		return;
	}
#ifdef WIN32
	static const char* userProfile = getenv("USERPROFILE");
#else
	static const char* userProfile = getenv("HOME");
#endif
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

// process ini file
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
#endif
	}
	// we should never get here, but if we do ...
	return std::string();
}

int setupDefaults(char *argv[])
{
	int retValue = 0;
	bool iniFileSet = false;
	TCUserDefaults::setCommandLine(argv);
	QtWebClientPlugin::registerPlugin();
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

			iniFileSet = TCUserDefaults::setIniFile(rcFilename);
			if (!iniFileSet)
			{
				printf("Error setting INI File to %s\n", rcFilename);

				rcFilename = copyString(homeDir, 128);

#ifdef WIN32
				ldviewrc = copyString("\\.config\\LDView\\ldview.ini");
#else
				ldviewrc = copyString("/.config/LDView/ldviewrc");
#endif

				strncat(rcFilename, ldviewrc, strlen(ldviewrc)+1);

				iniFileSet = TCUserDefaults::setIniFile(rcFilename);
			}
		}

		// Try to force the default ini at the executable root
		if (!iniFileSet)
		{
			retValue = 1;
			printf("Error setting INI File to %s\n", rcFilename);
#ifdef WIN32
			ldviewrc = copyString("ldview.ini");
#else
			ldviewrc = copyString("ldviewrc");
#endif
			iniFileSet = TCUserDefaults::setIniFile(ldviewrc);
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

		if(iniFileSet)
		{
			retValue = 0;
			QSettings::setDefaultFormat(QSettings::IniFormat);
			if (TCUserDefaults::boolForKey("Info"))
				printf("Using IniFile %s\n", rcFilename);
		}
	}

	const char *applicationName = "Travis Cobbs/LDView - LPub3D Edition";
	TCUserDefaults::setAppName(applicationName);

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

bool fileCaseLevel(QDir &dir, char *filename)
{
	int i;
	int len = strlen(filename);
	QString wildcard;
	QStringList files;

	if (!dir.isReadable())
	{
		return false;
	}
	for (i = 0; i < len; i++)
	{
		QChar letter = filename[i];

		if (letter.isLetter())
		{
			wildcard.append('[');
			wildcard.append(letter.toLower());
			wildcard.append(letter.toUpper());
			wildcard.append(']');
		}
		else
		{
			wildcard.append(letter);
		}
	}
	dir.setNameFilters(QStringList(wildcard));
	files = dir.entryList();
	if (files.count())
	{
		QString file = files[0];

		if (file.length() == (int)strlen(filename))
		{
			// This should never be false, but just want to be sure.
			strcpy(filename, file.toUtf8().constData());
			return true;
		}
	}
	return false;
}

bool fileCaseCallback(char *filename)
{
	char *shortName;
	QDir dir;
	char *firstSlashSpot;

	dir.setFilter(QDir::AllEntries | QDir::Readable | QDir::Hidden | QDir::System);
	replaceStringCharacter(filename, '\\', '/');
	firstSlashSpot = strchr(filename, '/');
	if (firstSlashSpot)
	{
		char *lastSlashSpot = strrchr(filename, '/');
		int dirLen;
		char *dirName;

		while (firstSlashSpot != lastSlashSpot)
		{
			char *nextSlashSpot = strchr(firstSlashSpot + 1, '/');

			dirLen = firstSlashSpot - filename + 1;
			dirName = new char[dirLen + 1];
			*nextSlashSpot = 0;
			strncpy(dirName, filename, dirLen);
			dirName[dirLen] = 0;
			if (dirLen)
			{
				dir.setPath(dirName);
				delete [] dirName;
				if (!fileCaseLevel(dir, firstSlashSpot + 1))
				{
					return false;
				}
			}
			firstSlashSpot = nextSlashSpot;
			*firstSlashSpot = '/';
		}
		dirLen = lastSlashSpot - filename;
		dirName = new char[dirLen + 1];
		strncpy(dirName, filename, dirLen);
		dirName[dirLen] = 0;
		dir.setPath(dirName);
		shortName = lastSlashSpot + 1;
		delete [] dirName;
	}
	else
	{
		shortName = filename;
	}
	return fileCaseLevel(dir, shortName);
}

bool doCommandLine(bool printInfo = false)
{
	SnapshotTaker *snapshotTaker = new SnapshotTaker();
	bool retValue = snapshotTaker->doCommandLine(printInfo);
	TCObject::release(snapshotTaker);
	return retValue;
}

int main(int argc, char *argv[])
{
	QLocale::setDefault(QLocale::system());
	setlocale(LC_CTYPE, "");

	printf("\nLDView CUI - LPub3D Edition (Offscreen Renderer) Version %s\n", LDViewVersion);
	printf("Built with Qt %s, running on Qt %s\n", QT_VERSION_STR, qVersion());
	printf("=========================================\n");

	bool printInfo = false;
	bool printArguments = false;
	bool defaultsOK = true;
	int retValue = 0;
	int stringTableSize = sizeof(LDViewMessages_bytes);
	char *stringTable = new char[sizeof(LDViewMessages_bytes) + 1];

	memcpy(stringTable, LDViewMessages_bytes, stringTableSize);
	stringTable[stringTableSize] = 0;
	TCLocalStrings::setStringTable(stringTable);

	if (setupDefaults(argv) != 0)
	{
		defaultsOK = false;
		retValue = 1;
	}

	QApplication a( argc, argv );

	printArguments = TCUserDefaults::boolForKey("Arguments");
	printInfo = TCUserDefaults::boolForKey("Info");
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

	if (defaultsOK)
	{
		TREMainModel::setStudTextureData(StudLogo_bytes, sizeof(StudLogo_bytes));
		LDLModel::setFileCaseCallback(fileCaseCallback);
		if (!doCommandLine(printInfo))
		{
			retValue = 2;
		}
	}

	TCAutoreleasePool::processReleases();

#ifdef __linux__
	KillThread *killThread = new KillThread;
	killThread->start();
#endif // __linux__

	return retValue;
}
