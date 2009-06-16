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
#import "TaskWrapper.h"
#import "BadgeView.h"
#import "GHostConfig.h"

@interface GHostController : NSObject <TaskWrapperController> {
	
    IBOutlet id logView;
    IBOutlet id startStopButton;
    IBOutlet id configSelector;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSPanel *progressPanel;
	IBOutlet NSPanel *newConfigPanel;
	TaskWrapper *ghost;
	IBOutlet BadgeView	*badge;
	IBOutlet GHostConfig *config;
	IBOutlet NSTextView *configEditor;
	NSArray *cfgfiles;
	IBOutlet NSButton *autoScrollCheckbox;
	BOOL running;
	NSString *configDir;
	NSString *ghostDir;
	NSString *libDir;
	NSMutableArray *lines;
	IBOutlet NSTableView *consoleTable;
	IBOutlet NSArrayController *listController;
	IBOutlet NSProgressIndicator *progressBar;
}
@property BOOL running;
@property(retain) NSArray *cfgfiles;
@property(retain) NSMutableArray *lines;
- (IBAction)startStop:(id)sender;
- (IBAction)restart:(id)sender;
//- (NSString*)getDir;
- (NSString *)getConfigDir;
- (NSString *)getGhostDir;
- (NSString *)applicationSupportFolder;
@end
