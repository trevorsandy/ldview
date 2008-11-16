/* LDViewController */

#import <Cocoa/Cocoa.h>

@class Preferences;
@class ModelWindow;
@class PrintAccessoryViewOwner;

@interface LDViewController : NSResponder
{
	IBOutlet NSMenuItem *statusBarMenuItem;
	IBOutlet NSMenuItem *toolbarMenuItem;
	IBOutlet NSMenuItem *custToolbarMenuItem;
	IBOutlet NSMenuItem *alwaysOnTopMenuItem;
	IBOutlet NSMenuItem *examineMenuItem;
	IBOutlet NSMenuItem *latLongRotationMenuItem;
	IBOutlet NSMenuItem *flyThroughMenuItem;
	IBOutlet NSMenuItem *cancelMenuItem;
	IBOutlet NSMenuItem *modelTreeMenuItem;
	IBOutlet NSMenuItem *pollingDisabledMenuItem;
	IBOutlet NSMenuItem *pollingPromptMenuItem;
	IBOutlet NSMenuItem *pollingAutoLaterMenuItem;
	IBOutlet NSMenuItem *pollingAutoNowMenuItem;
	IBOutlet NSMenuItem *copyMenuItem;
	IBOutlet NSMenuItem *prefsMenuItem;
	IBOutlet NSMenuItem *povCameraAspectMenuItem;

	IBOutlet NSMenu *fileMenu;
	IBOutlet NSMenu *viewingAngleMenu;
	IBOutlet NSMenu *standardSizesMenu;

	NSArray *ldrawFileTypes;
	NSMutableArray *modelWindows;
	Preferences *preferences;
	NSMutableArray *standardSizes;

	BOOL launchFileOpened;
	
	NSString *statusBarMenuFormat;
	NSString *toolbarMenuFormat;

	long pollingMode;
	NSTimer *tcAutoreleaseTimer;
	NSString *noWindowText;
	NSSize maxSize;
}

- (void)modelWindowWillClose:(ModelWindow *)modelWindow;
- (BOOL)verifyLDrawDir;
- (BOOL)verifyLDrawDir:(NSString *)ldrawDir prompt:(BOOL)prompt;
- (NSMenu *)viewingAngleMenu;
- (IBAction)newWindow:(id)sender;
- (IBAction)openModel:(id)sender;
- (IBAction)preferences:(id)sender;
- (Preferences *)preferences;
- (IBAction)resetView:(id)sender;
- (NSArray *)modelWindows;
- (void)updateStatusBarMenuItem:(BOOL)showStatusBar;
- (NSMenuItem *)statusBarMenuItem;
- (ModelWindow *)currentModelWindow;
- (long)pollingMode;
- (void)recordRecentFile:(NSString *)filename;
- (NSMenuItem *)prefsMenuItem;

@end
