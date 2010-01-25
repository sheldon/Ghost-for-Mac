// 
//  Server.m
//  Genie
//
//  Created by Lucas on 12.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Server.h"

#import "Bot.h"
#import "Channel.h"
#import "User.h"

@implementation Server 

@synthesize bnetObject;
@dynamic status;
@dynamic name;
@dynamic users;
@dynamic channel;
@dynamic bot;

- (User*)getUserForNick:(NSString*)nick
{
	NSEnumerator *e = [[self users] objectEnumerator];
	User *usr;
	while (usr = [e nextObject]) {
		if ([[usr name] isEqualToString:nick]) {
			return usr;
		}
	}
	usr = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[self managedObjectContext]];
	usr.name = nick;
	usr.server = self;
	[self addUsersObject:usr];
	return usr;
}

@end
