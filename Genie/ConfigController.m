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
#import "UIController.h"
#import "GHostConfigFile.h"


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

- (GHostConfigFile *)selectedConfig
{
	//return nil;
	NSArray *items = [cfgArrayController selectedObjects];
	if ([items count] > 0)
		return [items objectAtIndex:0];
	return nil;
}

- (void)reloadConfigList
{
	NSMutableArray *files  = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] directoryContentsAtPath: [UIController getConfigDir]]];
	//NSMutableArray *tmpcfgfiles = [NSMutableArray array];
	//NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[cfgArrayController arrangedObjects] count])];
	//[cfgArrayController removeObjectsAtArrangedObjectIndexes:set];
	for (int i=0;i<[[cfgArrayController arrangedObjects] count];i++)
	{
		NSString *filename = [[[cfgArrayController arrangedObjects] objectAtIndex:i] name];
		if (![files containsObject:filename])
		{
			[cfgArrayController removeObjectAtArrangedObjectIndex:i];
		}
		[files removeObject:filename];
	}
	
	for(NSString *cfg in files)
	{
		//NSLog(@"%@ - %@", cfg, [[cfg pathExtension] lowercaseString]);
		if ([[cfg pathExtension] caseInsensitiveCompare: @"cfg"] == NSOrderedSame)
		{
			GHostConfigFile *file = [[[GHostConfigFile alloc] initWithFile:[[UIController getConfigDir] stringByAppendingPathComponent:cfg]] autorelease];
			//[cfgArrayController addObject:file];
			//[secondController rearrangeObjects];
			[secondController addObject:file];
			[cfgArrayController rearrangeObjects];
		}
	}
	//self.cfgfiles = [NSArray arrayWithArray:tmpcfgfiles];
}

- (void)fsHandler:(NSNotification*)msg
{
	/*NSString *path = [[msg userInfo] valueForKey:@"path"];
	 if (!path)
	 path = @"N/A";
	 NSLog(@"%@ - %@",[msg name], path);*/
	[self reloadConfigList];
}

- (void)awakeFromNib
{
	[self reloadConfigList];
	[fileWatcher addPathToQueue:[UIController getConfigDir]];
    NSWorkspace* workspace = [NSWorkspace sharedWorkspace];
    NSNotificationCenter* notificationCenter = [workspace notificationCenter];
	[notificationCenter addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherRenameNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherWriteNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherDeleteNotification object:nil];
}

- (IBAction)revertConfig:(id)sender
{
	if (![self selectedConfig].isChanged || NSRunAlertPanel(@"Unsaved changes!",
															@"You have not saved the changes you made and are trying to (re)load a config.\nAre you sure you want to dismiss the changes made?",
															@"No", @"Yes", nil) == NSAlertAlternateReturn)
    [[self selectedConfig] revertContent];
}

- (IBAction)saveConfig:(id)sender
{
    [[self selectedConfig] saveContent];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)editConfig:(id)sender {
	if (![self selectedConfig].isChanged || NSRunAlertPanel(@"Unsaved changes!",
															@"You have not saved the changes you made and are trying to (re)load a config.\nAre you sure you want to dismiss the changes made?",
															@"No", @"Yes", nil) == NSAlertAlternateReturn)
		[[self selectedConfig] loadContent];
}

- (IBAction)newConfig:(id)sender {
	NSRunAlertPanel(@"Oops!", @"Features not available yet", @"OK", @"Too bad", @"It's not that hard!");
	/*[NSApp beginSheet: newConfigPanel
	 modalForWindow: mainWindow
	 modalDelegate: self
	 didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
	 contextInfo: nil];*/
}

- (IBAction)newConfigAccept:(id)sender
{
	[NSApp endSheet:newConfigPanel returnCode:NSOKButton];
}

- (IBAction)newConfigCancel:(id)sender
{
	[NSApp endSheet:newConfigPanel returnCode:NSCancelButton];
}

- (id)init
{
	self = [self initWithNibName:@"PreferencesConfig" bundle:nil];
	initDone = NO;
	fileWatcher = [[UKKQueue alloc] init];
	cfgfiles = [NSMutableArray array];
	return self;
}
@end
