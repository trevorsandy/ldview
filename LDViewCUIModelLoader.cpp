#include "LDViewCUIModelLoader.h"
#include "LDViewCUIWindow.h"
#include "ModelWindow.h"
#ifndef _MSC_VER
#include "GLInfo.h"
#endif

#include <LDLib/LDUserDefaultsKeys.h>
#include <LDLib/LDSnapshotTaker.h>
#include <LDLib/LDLibraryUpdater.h>
#include <LDLoader/LDLModel.h>

#include <TCFoundation/mystring.h>
#include <TCFoundation/TCAlert.h>
#include <TCFoundation/TCUserDefaults.h>
#include <TCFoundation/TCStringArray.h>
#include <TCFoundation/TCAlertManager.h>
#include <TCFoundation/TCLocalStrings.h>
#include <TCFoundation/TCProgressAlert.h>
#include <TCFoundation/TCWebClient.h>
#include <TRE/TREGLExtensions.h>
#include <CUI/CUIThemes.h>

#define WIN_WIDTH 640
#define WIN_HEIGHT 480

#define TITLE _UC("LDView")

LDViewCUIModelLoader::LDViewCUIModelLoader(HINSTANCE hInstance, bool glInfo)
			:modelWindow(NULL),
			 parentWindow(NULL),
			 hInstance(hInstance),
			 showGLInfo(glInfo),
			 offscreenSetup(false)
{
	init();
}

LDViewCUIModelLoader::~LDViewCUIModelLoader(void)
{
}

void LDViewCUIModelLoader::init(void)
{
	startup();
}

void LDViewCUIModelLoader::dealloc(void)
{
	TCAlertManager::unregisterHandler(this);
	if (modelWindow)
	{
		modelWindow->release();
	}
	if (parentWindow)
	{
		parentWindow->release();
	}
	TCObject::dealloc();
}

void LDViewCUIModelLoader::startup(void)
{
	int width;
	int height;
	int widthDelta = 0;
	const TCStringArray *commandLine = TCUserDefaults::getProcessedCommandLine();
	HWND hParentWindow = NULL;

	TCUserDefaults::removeValue(HFOV_KEY, false);
	TCUserDefaults::removeValue(CAMERA_GLOBE_KEY, false);
	if (commandLine)
	{
		int i;
		int count = commandLine->getCount();

		for (i = 0; i < count; i++)
		{
			const char *command = (*commandLine)[i];
			long long num;

			if (stringHasCaseInsensitivePrefix(command, "-ca"))
			{
				float value;

				if (sscanf(command + 3, "%f", &value) == 1)
				{
					TCUserDefaults::setFloatForKey(value, HFOV_KEY, false);
				}
			}
			else if (stringHasCaseInsensitivePrefix(command, "-cg"))
			{
				TCUserDefaults::setStringForKey(command + 3, CAMERA_GLOBE_KEY,
					false);
			}
			else if (strcasecmp(command, "-float") == 0 && i + 1 < count &&
				sscanf((*commandLine)[i + 1], "%lli", &num) == 1 && num != 0)
			{
				hParentWindow = (HWND)num;
			}
		}
	}
	float widthf = TCUserDefaults::floatForKey(
		LDViewWindow::getFloatUdKey(WINDOW_WIDTH_KEY).c_str(), -1.0, false);
	float heightf = TCUserDefaults::floatForKey(
		LDViewWindow::getFloatUdKey(WINDOW_HEIGHT_KEY).c_str(), -1.0, false);
	if (widthf == -1.0)
	{
		width = TCUserDefaults::longForKey(WINDOW_WIDTH_KEY, WIN_WIDTH, false);
	}
	else
	{
		width = (int)widthf;
	}
	if (heightf == -1.0)
	{
		height = TCUserDefaults::longForKey(WINDOW_HEIGHT_KEY, WIN_HEIGHT, false);
	}
	else
	{
		height = (int)heightf;
	}
	parentWindow = new LDViewWindow(TITLE, hInstance, CW_USEDEFAULT,
		CW_USEDEFAULT, width + widthDelta, height);
	parentWindow->setMinWidth(320);
	parentWindow->setMinHeight(240);
	if (hParentWindow)
	{
		parentWindow->setHParentWindow(hParentWindow);
	}
	if (parentWindow->initWindow())
	{
		UCSTR snapshotFilename =
			TCUserDefaults::stringForKeyUC(SAVE_SNAPSHOT_KEY, NULL, false);
		modelWindow = parentWindow->getModelWindow();
		modelWindow->retain();
		if (snapshotFilename != NULL)
		{
			UCCHAR originalDir[MAX_PATH];
			UCCHAR fullFilename[MAX_PATH];

			GetCurrentDirectoryW(COUNT_OF(originalDir), originalDir);
			if (snapshotFilename != NULL)
			{
				if (ModelWindow::chDirFromFilename(snapshotFilename,
					fullFilename))
				{
					delete[] snapshotFilename;
					SetCurrentDirectoryW(originalDir);
				}
			}
		}
		TCAlertManager::registerHandler(LDSnapshotTaker::alertClass(), this,
			(TCAlertCallback)&LDViewCUIModelLoader::snapshotCallback);
		LDrawModelViewer::setAppVersion(LDViewWindow::getAppVersion());
		LDrawModelViewer::setAppCopyright(LDViewWindow::getAppAsciiCopyright());
		//LDLModel::setFileCaseCallback(LDViewWindow::fileCaseCallback);
		if (showGLInfo)
		{
			printOpenGLDriverInfo();
		}
		if (LDSnapshotTaker::doCommandLine())
		{
			parentWindow->shutdown();
			modelWindow->cleanupOffscreen();
		}
	}
}

void LDViewCUIModelLoader::printOpenGLDriverInfo()
{
#ifdef _MSC_VER
	int extensionCount;
	UCSTR extensions = LDrawModelViewer::getOpenGLDriverInfo(extensionCount);
	printf("\nOpenGL Driver Info\n==========================\n");
	printf("%ls ", extensions);
	printf("\n%d %ls", extensionCount, (TCLocalStrings::get(L"OpenGlnExtensionsSuffix")));
	printf("\n==========================\n");
#else
	GLInfo glInfo;
	glInfo.printGLInfo();
#endif
}

void LDViewCUIModelLoader::snapshotCallback(TCAlert *alert)
{
	if (strcmp(alert->getMessage(), "PreSave") == 0 && !offscreenSetup)
	{
		if (modelWindow->setupOffscreen(1600, 1200,
			TCUserDefaults::longForKey(FSAA_MODE_KEY) > 0))
		{
			offscreenSetup = true;
		}
		else
		{
			LDSnapshotTaker *sender = (LDSnapshotTaker *)alert->getSender();
			sender->cancel();
		}
	}
}
