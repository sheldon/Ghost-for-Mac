/*
 This file is part of Genie.
 Copyright 2009 Lucas Romero
 
 Genie is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Genie is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Genie.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Cocoa/Cocoa.h>
#import "ConfigController.h"
#import "BadgeView.h"
#import "GeneralController.h"
#import "ConfigController.h"
#import "MapController.h"
#import "ghost4mac/GHostController.h"
#import "AsyncUdpSocket.h"
#import "LRViewController.h"
#import "ConsoleViewController.h"
#import	"ChatViewController.h"
#import "MessagesController.h"

@interface UIController : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *prefWindow;
	IBOutlet NSPopUpButton *configSelector;
	IBOutlet NSButton *autoScrollCheckbox;
	IBOutlet NSToolbarItem *startStopButton;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet BadgeView *badge;
	IBOutlet NSPanel *progressPanel;
	IBOutlet NSArrayController *listController;
	IBOutlet ConfigController *configController;
	IBOutlet GeneralController *generalController;
	IBOutlet MapController *mapController;
	IBOutlet NSMenu *showHideHeaderMenu;
	NSMutableArray *lines;
	GHostController *ghost;
	IBOutlet NSProgressIndicator *portMapProgress;
	IBOutlet NSImageView *portMapStatus;
	IBOutlet NSTextField *portMapText;
	IBOutlet ConsoleViewController *consoleView;
	IBOutlet ChatViewController *chatView;
	IBOutlet MessagesController *msgController;
	IBOutlet NSView *mainView;
	IBOutlet NSTextField *ghostVersion;
	int currentViewTag;
}
@property(retain) NSMutableArray *lines;
+ (NSString *)getConfigDir;
+ (NSString *)applicationSupportFolder;
- (IBAction)selectFont:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (IBAction)startStop:(id)sender;
- (IBAction)restart:(id)sender;
- (IBAction)switchView:(id)sender;
- (void)appendOutput:(NSString *)output;
@end
