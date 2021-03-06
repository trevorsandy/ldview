//
//  ModelTree.h
//  LDView
//
//  Created by Travis Cobbs on 3/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HelperPanel.h"

@class ModelTreeItem;

class LDModelTree;

@interface ModelTree : HelperPanel
{
	IBOutlet NSOutlineView *outlineView;
	IBOutlet NSTextField *optionsBoxLabel;
	IBOutlet NSBox *optionsBox;
	IBOutlet NSButton *showHideOptionsButton;
	IBOutlet NSMatrix *optionsMatrix;
	IBOutlet NSButton *highlightCheck;
	IBOutlet NSTextField *statusTextField;
	IBOutlet NSColorWell *highlightColorWell;
//    IBOutlet NSLayoutConstraint *showLinesBottomConstraint;
	LDModelTree *modelTree;
	ModelTreeItem *rootModelTreeItem;
	float showHideStartY;
	NSLayoutConstraint *optionsBoxHiddenConstraint;
	CGFloat optionsBoxHeight;
//    CGFloat showLinesBottomConstraintConstant;
}

- (void)modelChanged:(NSNotification *)notification;
- (void)hideOptions;
- (void)showOptions;
- (NSOutlineView *)outlineView;
- (BOOL)canCopy;
- (IBAction)copy:(id)sender;
- (void)updateHighlight;

@end
