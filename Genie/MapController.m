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

#import "MapController.h"
#import "GHostConfigFile.h"
#import "ghost4mac/GHostController.h"
#import "UKKQueue.h"

@implementation MapController
@synthesize mapconfigs;
- (NSString *)title
{
	return NSLocalizedString(@"Maps", @"Title of 'Maps' preference pane");
}

- (NSString *)identifier
{
	return @"MapsPrefPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"Map128.png"];
}

- (IBAction)addMaps:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: mapDir]];
}


- (void)refreshMaps
{
	NSMutableArray *configs  = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] directoryContentsAtPath: mapDir]];
	//self.mapconfigs = [NSMutableArray array];
	//NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, )];
	//[mapconfigController removeObjectsAtArrangedObjectIndexes:set];
	for (int i=0;i<[[mapconfigController arrangedObjects] count];i++)
	{
		NSString *filename = [[[mapconfigController arrangedObjects] objectAtIndex:i] name];
		if (![configs containsObject:filename])
		{
			[mapconfigController removeObjectAtArrangedObjectIndex:i];
		}
		[configs removeObject:filename];
	}
	
	for(NSString *cfg in configs)
	{
		if ([[cfg pathExtension] caseInsensitiveCompare: @"w3x"] == NSOrderedSame /*&& ![[mapconfigController arrangedObjects] containsObject:cfg]*/)
			[mapconfigController addObject: [[GHostConfigFile alloc] initWithFile:[mapDir stringByAppendingPathComponent:cfg]]];
	}
}

- (void)willBeDisplayed
{
	[self refreshMaps];
}

- (void)fsHandler:(NSNotification*)msg
{
	/*NSString *path = [[msg userInfo] valueForKey:@"path"];
	if (!path)
		path = @"N/A";
	NSLog(@"%@ - %@",[msg name], path);*/
	[self refreshMaps];
}

- (void)awakeFromNib
{
	mapDir = [[[GHostController sharedController] ghostDir] stringByAppendingPathComponent:@"maps"];
	[fileWatcher addPathToQueue:mapDir];
    NSWorkspace* workspace = [NSWorkspace sharedWorkspace];
    NSNotificationCenter* notificationCenter = [workspace notificationCenter];
	[notificationCenter addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherRenameNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherWriteNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherDeleteNotification object:nil];
	[self refreshMaps];
}

- (id)init
{
	self = [self initWithNibName:@"PreferencesMaps" bundle:nil];
	self.mapconfigs = [NSMutableArray array];
	fileWatcher = [[UKKQueue alloc] init];
    
	return self;
}
@end
