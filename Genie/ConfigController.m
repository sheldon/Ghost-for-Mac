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

#import "ConfigController.h"
#import "UIController.h";


@implementation ConfigController
@synthesize cfgfiles;
- (NSString *)title
{
	return NSLocalizedString(@"Configs", @"Title of 'Configs' preference pane");
}

- (NSString *)identifier
{
	return @"ConfigsPrefPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSAdvanced"];
}

- (void)willBeDisplayed
{
	if ([[textEdit textStorage] length] == 0)
		[self editConfig:configSelector];
}

- (IBAction)revertConfig:(id)sender {
    [config revertFile];
}

- (IBAction)saveConfig:(id)sender {
    [config saveFile];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)editConfig:(id)sender {
	[config loadFile:[[UIController getConfigDir] stringByAppendingPathComponent: [[sender selectedItem] title]]];
}

- (IBAction)newConfig:(id)sender {
	NSRunAlertPanel(@"Oops!", @"Features not available yet", @"OK", @"Too bad", @"It's not that hard!");
	/*[NSApp beginSheet: newConfigPanel
	 modalForWindow: mainWindow
	 modalDelegate: self
	 didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
	 contextInfo: nil];*/
}

- (IBAction)newConfigAccept:(id)sender {
	[NSApp endSheet:newConfigPanel returnCode:NSOKButton];
}

- (IBAction)newConfigCancel:(id)sender {
	[NSApp endSheet:newConfigPanel returnCode:NSCancelButton];
}

- (id)init
{
	self = [self initWithNibName:@"PreferencesConfig" bundle:nil];
	NSArray *configs  = [[NSFileManager defaultManager] directoryContentsAtPath: [UIController getConfigDir]];
	NSMutableArray *tmpcfgfiles = [NSMutableArray array];
	
	for(NSString *cfg in configs)
	{
		//NSLog(@"%@ - %@", cfg, [[cfg pathExtension] lowercaseString]);
		if ([[cfg pathExtension] caseInsensitiveCompare: @"cfg"] == NSOrderedSame)
			[tmpcfgfiles addObject: cfg];
	}
	self.cfgfiles = [NSArray arrayWithArray:tmpcfgfiles];
	return self;
}
@end
