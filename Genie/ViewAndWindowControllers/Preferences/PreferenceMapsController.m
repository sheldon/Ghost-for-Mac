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

#import "PreferenceMapsController.h"

@implementation PreferenceMapsController
@synthesize managedObjectContext;
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

- (NSString *)applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Genie"];
}

- (IBAction)manageMaps:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:
	 [NSURL fileURLWithPath:
	  [[self applicationSupportDirectory] stringByAppendingPathComponent:@"Warcraft III Maps"]
	  ]
	 ];
}

- (void)willBeDisplayed
{
	//[self refreshMaps];
}

- (void)awakeFromNib
{

}

- (id)initWithObjectContext:(NSManagedObjectContext*)context
{
	if (self = [self initWithNibName:@"PreferenceMaps" bundle:nil]) {
		managedObjectContext = context;
	}
	return self;
}
@end
