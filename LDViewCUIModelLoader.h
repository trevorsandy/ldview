#ifndef __LDVIEWCUIMODELLOADER_H__
#define __LDVIEWCUIMODELLOADER_H__

#include <TCFoundation/TCObject.h>
#include <CUI/CUIWindow.h>

#include <windows.h>

class LDViewWindow;
class ModelWindow;
class TCProgressAlert;
class TCAlert;

class LDViewCUIModelLoader: public TCObject
{
	public:
	LDViewCUIModelLoader(HINSTANCE hInstance, bool glInfo = false);
	protected:
		~LDViewCUIModelLoader(void);
		virtual void dealloc(void);
		void init(void);
		virtual void startup(void);
		void printOpenGLDriverInfo();
		void snapshotCallback(TCAlert *alert);

		ModelWindow *modelWindow;
		LDViewWindow *parentWindow;
		HINSTANCE hInstance;
		bool showGLInfo;
		bool offscreenSetup;
};

#endif
