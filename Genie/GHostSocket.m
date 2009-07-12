//
//  GHostSocket.m
//  Genie
//
//  Created by Lucas on 12.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GHostSocket.h"


@implementation GHostSocket

- (void)sendCommand:(NSString*)cmd {
	if (!cmdSock)
		return;
	[cmdSock sendData:[cmd dataUsingEncoding:NSUTF8StringEncoding] withTimeout:30 tag:0];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
	//NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 1)];
	NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		if ([msg isEqualToString:@"PING"])
			[self sendCommand:@"\n"];
	}
	[cmdSock receiveWithTimeout:-1 tag:0];
	return YES;
}

- (void)initWithPort:(NSInteger)port
{
	if (cmdSock)
		[cmdSock release];
	cmdSock = [[AsyncUdpSocket alloc] initWithDelegate:self];
	[cmdSock connectToHost:@"localhost" onPort:port error:nil];
	[cmdSock receiveWithTimeout:-1 tag:0];
	[self sendCommand:@"\n"];
}

static GHostSocket *sharedSocket = nil;

+ (GHostSocket*)sharedSocket
{
    @synchronized(self) {
        if (sharedSocket == nil) {
            [[self alloc] init];
        }
    }
    return sharedSocket;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedSocket == nil) {
            return [super allocWithZone:zone];
        }
    }
    return sharedSocket;
}

- (id)init
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if (sharedSocket == nil) {
            if (self = [super init]) {
                sharedSocket = self;
                // custom initialization here
            }
        }
    }
    return sharedSocket;
}

- (id)copyWithZone:(NSZone *)zone { return self; }

- (id)retain { return self; }

- (unsigned)retainCount { return UINT_MAX; }

- (void)release {}

- (id)autorelease { return self; }
@end
