#include "LDViewCUIWindow.h"
#include "ModelWindow.h"
#include "Resource.h"

#include <LDLib/LDUserDefaultsKeys.h>
#include <LDLoader/LDLMainModel.h>

#include <TCFoundation/mystring.h>
#include <TCFoundation/TCUserDefaults.h>
#include <TCFoundation/TCAlert.h>
#include <TCFoundation/TCAlertManager.h>
#include <TCFoundation/TCWebClient.h>
#include <shlobj.h>
#include <string>
#if !defined(_MSC_VER)
#include <dirent.h>
#endif
#include <map>

#define DEFAULT_WIN_WIDTH 640
#define DEFAULT_WIN_HEIGHT 480

typedef std::map<std::string, std::string> StringMap;

UCCHAR *LDViewWindow::productVersion = NULL;
UCCHAR *LDViewWindow::legalCopyright = NULL;
TCStringArray *LDViewWindow::extraSearchDirs = NULL;
LDViewWindow::LDViewWindowCleanup LDViewWindow::ldViewWindowCleanup;
LDViewWindow::LDViewWindowCleanup::~LDViewWindowCleanup(void)
{
	TCObject::release(LDViewWindow::extraSearchDirs);
	LDViewWindow::extraSearchDirs = NULL;
	delete[] LDViewWindow::legalCopyright;
	LDViewWindow::legalCopyright = NULL;
	delete[] LDViewWindow::productVersion;
	LDViewWindow::productVersion = NULL;
}

LDViewWindow::LDViewWindow(CUCSTR windowTitle, HINSTANCE hInstance, int x,
						   int y, int width, int height):
CUIWindow(windowTitle, hInstance, x, y, width, height),
modelWindow(NULL),
fullScreen(false)
{
	CUIThemes::init();
	if (CUIThemes::isThemeLibLoaded())
	{
		if (TCUserDefaults::boolForKey(VISUAL_STYLE_ENABLED_KEY, true, false))
		{
			CUIThemes::setThemeAppProperties(STAP_ALLOW_NONCLIENT |
				STAP_ALLOW_CONTROLS);
		}
		else
		{
			CUIThemes::setThemeAppProperties(STAP_ALLOW_NONCLIENT);
		}
	}
	if (!extraSearchDirs)
	{
		extraSearchDirs = new TCStringArray;
		populateExtraSearchDirs();
	}
	UCCHAR ucUserAgent[256];
	sucprintf(ucUserAgent, COUNT_OF(ucUserAgent),
		_UC("LDView/%s  (Windows; ldview@gmail.com; ")
		_UC("https://github.com/tcobbs/ldview)"), getProductVersion());
	std::string userAgent;
	ucstringtoutf8(userAgent, ucUserAgent);
	TCWebClient::setUserAgent(userAgent.c_str());
}

LDViewWindow::~LDViewWindow(void)
{
}

BOOL LDViewWindow::initWindow(void)
{
	if (!modelWindow)
	{
		createModelWindow();
	}
	if (hParentWindow)
	{
		windowStyle = WS_CHILD;
	}
	else
	{
		if (TCUserDefaults::boolForKey(TOPMOST_KEY, false, false))
		{
			exWindowStyle |= WS_EX_TOPMOST;
		}
		else
		{
			exWindowStyle &= ~WS_EX_TOPMOST;
		}
	}
	DWORD origThemeAppProps = CUIThemes::getThemeAppProperties();

	if (TCUserDefaults::boolForKey(FORCE_THEMED_MENUS_KEY, false, false))
	{
		CUIThemes::setThemeAppProperties(STAP_ALLOW_NONCLIENT |
			STAP_ALLOW_CONTROLS);
	}
	if (CUIWindow::initWindow())
	{
		CUIThemes::setThemeAppProperties(origThemeAppProps);
		return modelWindow->initWindow();
	}
	return FALSE;
}

void LDViewWindow::createModelWindow(void)
{
	TCObject::release(modelWindow);
	int lwidth = getSavedWindowWidth();
	int lheight = getSavedWindowHeight();
	modelWindow = new ModelWindow(this, 0, 0, lwidth, lheight);
}

void LDViewWindow::shutdown(void)
{
	if (modelWindow)
	{
		ModelWindow *tmpModelWindow = modelWindow;
		modelWindow = NULL;
		tmpModelWindow->closeWindow();
		tmpModelWindow->release();
	}
	DestroyWindow(hWindow);
}

void LDViewWindow::dealloc(void)
{
	TCAlertManager::unregisterHandler(this);
	CUIWindow::dealloc();
}

void LDViewWindow::populateExtraSearchDirs(void)
{
	int i;

	extraSearchDirs->removeAll();
	for (i = 1; true; i++)
	{
		char key[128];
		char *extraSearchDir;

		snprintf(key, sizeof(key), "%s/Dir%03d", EXTRA_SEARCH_DIRS_KEY, i);
		extraSearchDir = TCUserDefaults::stringForKey(key, NULL, false);
		if (extraSearchDir)
		{
			extraSearchDirs->addString(extraSearchDir);
			delete extraSearchDir;
		}
		else
		{
			break;
		}
	}
}

int LDViewWindow::getSavedPixelSize(const char *udKey, int defaultSize)
{
	std::string floatUdKey = getFloatUdKey(udKey);
	double size = TCUserDefaults::floatForKey(floatUdKey.c_str(), -1.0, false);
	if (size == -1.0)
	{
		size = TCUserDefaults::longForKey(udKey, defaultSize, true);
	}
	return (int)(size * getScaleFactor());
}

int LDViewWindow::getSavedWindowWidth(int defaultValue /*= -1*/)
{
	return getSavedPixelSize(WINDOW_WIDTH_KEY,
		defaultValue == -1 ? DEFAULT_WIN_WIDTH : defaultValue);
}

int LDViewWindow::getSavedWindowHeight(int defaultValue /*= -1*/)
{
	return getSavedPixelSize(WINDOW_HEIGHT_KEY,
		defaultValue == -1 ? DEFAULT_WIN_HEIGHT : defaultValue);
}

std::string LDViewWindow::getFloatUdKey(const char* udKey)
{
	std::string floatUdKey = udKey;
	floatUdKey += "Float";
	return floatUdKey;
}

const std::string LDViewWindow::getAppVersion(void)
{
	std::string utf8ProductVersion;
	ucstringtoutf8(utf8ProductVersion, getProductVersion());
	return utf8ProductVersion;
}

const std::string LDViewWindow::getAppAsciiCopyright(void)
{
	std::string copyright;
	ucstringtoutf8(copyright, getLegalCopyright());
	std::string copyrightSym = "\xC2\xA9"; // UTF-8 character sequence
	size_t index = copyright.find(copyrightSym);

	if (index < copyright.size())
	{
		copyright.replace(index, copyrightSym.size(), "(C)");
	}
	return copyright;
}

const UCCHAR *LDViewWindow::getProductVersion(void)
{
	if (!productVersion)
	{
		readVersionInfo();
	}
	return productVersion;
}

const UCCHAR *LDViewWindow::getLegalCopyright(void)
{
	if (!legalCopyright)
	{
		readVersionInfo();
	}
	return legalCopyright;
}

void LDViewWindow::readVersionInfo(void)
{
	UCCHAR moduleFilename[1024];

	if (productVersion != NULL)
	{
		return;
	}
	if (GetModuleFileName(NULL, moduleFilename, COUNT_OF(moduleFilename)) > 0)
	{
		DWORD zero;
		DWORD versionInfoSize = GetFileVersionInfoSize(moduleFilename, &zero);

		if (versionInfoSize > 0)
		{
			BYTE *versionInfo = new BYTE[versionInfoSize];

			if (GetFileVersionInfo(moduleFilename, 0, versionInfoSize,
				versionInfo))
			{
				UCCHAR *value;
				UINT versionLength;

				if (VerQueryValue(versionInfo,
					_UC("\\StringFileInfo\\040904B0\\ProductVersion"),
					(void**)&value, &versionLength))
				{
					productVersion = copyString(value);
				}
				if (VerQueryValue(versionInfo,
					_UC("\\StringFileInfo\\040904B0\\LegalCopyright"),
					(void**)&value, &versionLength))
				{
					legalCopyright = copyString(value);
				}
			}
			delete[] versionInfo;
		}
	}
}
