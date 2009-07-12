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
#import "GHostMapConfig.h"
#import "ghost4mac/GHostController.h"

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
	return [NSImage imageNamed:@"map.png"];
}

- (void)textDidBeginEditing:(NSNotification *)note {
	NSLog(@"lol");
}

- (void)awakeFromNib
{
	NSArray *configs  = [[NSFileManager defaultManager] directoryContentsAtPath: mapDir];
	NSLog(mapDir);
	for(NSString *cfg in configs)
	{
		NSLog(@"%@ - %@", cfg, [[cfg pathExtension] lowercaseString]);
		if ([[cfg pathExtension] caseInsensitiveCompare: @"cfg"] == NSOrderedSame)
			[mapconfigController addObject: [[GHostMapConfig alloc] initWithFile:[mapDir stringByAppendingPathComponent:cfg]]];
	}
}

- (id)init
{
	self = [self initWithNibName:@"PreferencesMaps" bundle:nil];
	mapconfigs = [NSMutableArray array];
	mapDir = [[[GHostController sharedController] ghostDir] stringByAppendingPathComponent:@"mapcfgs"];
	
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditing:) name:NSControlTextDidBeginEditingNotification object:nil];
	return self;
}
@end
