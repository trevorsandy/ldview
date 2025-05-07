#ifndef __LDVIEWCUIWINDOW_H__
#define __LDVIEWCUIWINDOW_H__

#include <TCFoundation/TCObject.h>
#include <CUI/CUIWindow.h>

#include <windows.h>

class ModelWindow;
class TCStringArray;

class LDViewWindow: public CUIWindow
{
	public:
		LDViewWindow(CUCSTR, HINSTANCE, int, int, int, int);
		virtual ~LDViewWindow(void);

		virtual BOOL initWindow(void);
		virtual void createModelWindow(void);
		virtual void shutdown(void);
		virtual void dealloc(void);
		virtual void populateExtraSearchDirs(void);

		int getSavedPixelSize(const char *udKey, int defaultSize);
		int getSavedWindowWidth(int defaultValue = -1);
		int getSavedWindowHeight(int defaultValue = -1);

		static std::string getFloatUdKey(const char *udKey);
		static const std::string getAppVersion(void);
		static const std::string getAppAsciiCopyright(void);
		static const UCCHAR *getProductVersion(void);
		static const UCCHAR *getLegalCopyright(void);
		static void readVersionInfo(void);

		void setHParentWindow(HWND hWnd) { hParentWindow = hWnd; }
		ModelWindow *getModelWindow(void) {	return modelWindow; }

		ModelWindow *modelWindow;
		bool fullScreen;

		static UCCHAR *productVersion;
		static UCCHAR *legalCopyright;
		static TCStringArray *extraSearchDirs;

		static class LDViewWindowCleanup
		{
			public:
				~LDViewWindowCleanup(void);
		} ldViewWindowCleanup;
		friend class LDViewWindowCleanup;
};

#endif
