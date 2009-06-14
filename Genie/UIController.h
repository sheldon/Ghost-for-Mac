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
#import "GHostController.h"

@interface UIController : NSObject {
    IBOutlet id configSelector;
	IBOutlet NSWindow *mainWindow;
    IBOutlet GHostController *ghostController;
    IBOutlet NSTextView *textEdit;
	IBOutlet GHostConfig *config;
	IBOutlet id commandLine;
	IBOutlet NSPanel *newConfigPanel;
	IBOutlet NSTextField *newConfigName;
}
- (IBAction)editConfig:(id)sender;
- (IBAction)newConfig:(id)sender;
- (IBAction)selectFont:(id)sender;
- (IBAction)openGhostDir:(id)sender;
- (IBAction)openConfigDir:(id)sender;
- (IBAction)revertConfig:(id)sender;
- (IBAction)saveConfig:(id)sender;
- (IBAction)newConfigAccept:(id)sender;
- (IBAction)newConfigCancel:(id)sender;
@end
