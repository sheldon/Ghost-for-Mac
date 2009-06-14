//
//  GHostRemoteServer.m
//  Genie
//
//  Created by Lucas on 12.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GHostRemoteServer.h"


@implementation GHostRemoteServer
- (id) initWithServer: (NSString*) host
{
	return [self initWithServer: host port: 6969];
}
- (id) initWithServer: (NSString*) host port: (short) port
{
	self = [[super alloc] init];
	return self;
}
@end
