//
//  MessagesController.m
//  Genie
//
//  Created by Lucas on 04.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MessagesController.h"


@implementation MessagesController
- (NSString *)title
{
	return NSLocalizedString(@"Messages", @"Title of 'Messages' preference pane");
}

- (NSString *)identifier
{
	return @"MessagesPrefPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPathTemplate"];
}

- (void)willBeDisplayed
{
	
}

- (id)init
{
	self = [self initWithNibName:@"PreferencesMessages" bundle:nil];
	return self;
}

@end
