//
//  GHostRemoteServer.h
//  Genie
//
//  Created by Lucas on 12.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GHostServer.h"

@interface GHostRemoteServer : GHostServer {

}
- (id) initWithServer: (NSString*) host;
- (id) initWithServer: (NSString*) host port: (short) port;

@end
