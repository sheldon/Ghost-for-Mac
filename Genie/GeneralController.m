//
//  GeneralController.m
//  Genie
//
//  Created by Lucas on 19.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GeneralController.h"
#import "GHostController.h"


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
    [[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: [GHostController getGhostDir]]];
}

- (IBAction)openConfigDir:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: [GHostController getConfigDir]]];
}

- (IBAction)clearAppSupport:(id)sender {
	if (NSRunCriticalAlertPanel(@"Are you sure?", @"You are about to TRASH ALL GHost configuration files and your GHost database. The files will be moved to your trash and can be recovered from there.\n\nAre you REALLY sure you want to do this?", @"No", @"Yes, I want to trash everything", nil) == NSAlertAlternateReturn) {
		FSRef ref;
		FSPathMakeRef( (const UInt8 *)[[GHostController applicationSupportFolder] fileSystemRepresentation], &ref, NULL );
		FSMoveObjectToTrashSync(&ref, NULL, kFSFileOperationDoNotMoveAcrossVolumes);
	}
}

- (id)init
{
	self = [self initWithNibName:@"PreferencesGeneral" bundle:nil];
	return self;
}
@end
