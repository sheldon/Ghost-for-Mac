// 
//  ChatMessage.m
//  Genie
//
//  Created by Lucas on 11.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChatMessage.h"

#import "Channel.h"
#import "User.h"

@implementation ChatMessage 

@dynamic channel;
@dynamic sender;

- (NSImage*)icon
{
	if (self.channel)
	{
		return [NSImage imageNamed:NSImageNameUserGroup];
	}
	return [NSImage imageNamed:NSImageNameUser];
}

@end
