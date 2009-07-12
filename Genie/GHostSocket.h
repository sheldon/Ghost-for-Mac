//
//  GHostSocket.h
//  Genie
//
//  Created by Lucas on 12.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncUdpSocket.h"


@interface GHostSocket : NSObject {
	AsyncUdpSocket *cmdSock;
}
+ (GHostSocket*)sharedSocket;
- (void)sendCommand:(NSString*)cmd;
- (void)initWithPort:(NSInteger)port;
@end
