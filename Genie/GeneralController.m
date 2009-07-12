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

#import "GeneralController.h"
#import "UIController.h"
#import "ghost4mac/GHostController.h"


@implementation GeneralController
- (NSString *)title
{
	return NSLocalizedString(@"General", @"Title of 'General' preference pane");
}

- (NSString *)identifier
{
	return @"GeneralPrefPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}


- (IBAction)openGhostDir:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: [GHostController sharedController].ghostDir]];
}

- (IBAction)openConfigDir:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: [UIController getConfigDir]]];
}

- (IBAction)clearAppSupport:(id)sender {
	if (NSRunCriticalAlertPanel(@"Are you sure?", @"You are about to TRASH ALL GHost configuration files and your GHost database. The files will be moved to your trash and can be recovered from there.\n\nAre you REALLY sure you want to do this?", @"No", @"Yes, I want to trash everything", nil) == NSAlertAlternateReturn) {
		FSRef ref;
		FSPathMakeRef( (const UInt8 *)[[UIController applicationSupportFolder] fileSystemRepresentation], &ref, NULL );
		FSMoveObjectToTrashSync(&ref, NULL, kFSFileOperationDoNotMoveAcrossVolumes);
	}
}

- (id)init
{
	self = [self initWithNibName:@"PreferencesGeneral" bundle:nil];
	return self;
}
@end
