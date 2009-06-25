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

#import "GHostController.h"

@implementation GHostController
@synthesize ghostDir;
@synthesize config;
@synthesize running;

NSString * const GHConsoleOutput = @"GHConsoleOutput";
NSString * const GHSocketOutput = @"GHSocketOutput";
NSString * const GHProcessStarted = @"GHProcessStarted";
NSString * const GHProcessStopped = @"GHProcessStopped";

static GHostController *sharedController = nil;

+ (GHostController*)sharedController
{
    @synchronized(self) {
        if (sharedController == nil) {
            [[self alloc] init];
        }
    }
    return sharedController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedController == nil) {
            return [super allocWithZone:zone];
        }
    }
    return sharedController;
}

- (id)init
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if (sharedController == nil) {
            if (self = [super init]) {
                sharedController = self;
                // custom initialization here
				self.running = NO;
				[[NSNotificationCenter defaultCenter]
				 addObserver:self
				 selector:@selector(doTerminate:)
				 name:NSApplicationWillTerminateNotification
				 object:NSApp];
            }
        }
    }
    return sharedController;
}

- (id)copyWithZone:(NSZone *)zone { return self; }

- (id)retain { return self; }

- (unsigned)retainCount { return UINT_MAX; }

- (void)release {}

- (id)autorelease { return self; }

- (void)doTerminate:(NSNotification *)note
{
	[self stop];
}

- (void)startWithConfig:(NSString*)cfg {
	@synchronized(self) {
		//[startButton setTitle:@"Running..."];
		if (ghost!=nil)
			[ghost release];
		if (![[NSFileManager defaultManager] fileExistsAtPath:cfg])
			cfg = @"";
		// Let's allocate memory for and initialize a new TaskWrapper object, passing
		// in ourselves as the controller for this TaskWrapper object, the path
		// to the command-line tool, and the contents of the text field that 
		// displays what the user wants to search on
		ghost=[[TaskWrapper alloc]
			   initWithController:self
			   execpath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent: @"ghost++"]
			   workdir:self.ghostDir
			   environment:[NSDictionary dictionaryWithObjectsAndKeys:
							[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent: @"lib"],
							@"DYLD_FALLBACK_LIBRARY_PATH",
							nil]

			   arguments:[NSArray arrayWithObject:cfg]];
		// kick off the process asynchronously
		[ghost startProcess];
		if (cmdSock)
			[cmdSock release];
		cmdSock = [[AsyncUdpSocket alloc] initWithDelegate:self];
		[cmdSock connectToHost:@"localhost" onPort:6969 error:nil];
		[cmdSock receiveWithTimeout:-1 tag:0];
		[self sendCommand:@"\n"];
	}
}

- (void)stop {
	@synchronized(self) {
	[ghost stopProcess];
	// Release the memory for this wrapper object
	[ghost release];
	ghost = nil;
	[cmdSock release];
	cmdSock = nil;
	}
}

- (void)sendCommand:(NSString*)cmd {
	[cmdSock sendData:[cmd dataUsingEncoding:NSUTF8StringEncoding] withTimeout:30 tag:0];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
	//NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 1)];
	NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		if ([msg isEqualToString:@"PING"])
			[self sendCommand:@"\n"];
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:GHSocketOutput object:self userInfo:[NSDictionary dictionaryWithObject:msg forKey:@"line"]];
	}
	else
	{
		[self appendOutput:@"Error converting received data into NSUTF8StringEncoding String"];
	}
	[cmdSock receiveWithTimeout:-1 tag:0];
	return YES;
}

// This callback is implemented as part of conforming to the ProcessController protocol.
// It will be called whenever there is output from the TaskWrapper.
- (void)appendOutput:(NSString *)output
{
	NSLog(output);
	NSArray *printlines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	for(NSString* line in printlines) {
		line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([line length] > 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:GHConsoleOutput object:self userInfo:[NSDictionary dictionaryWithObject:line forKey:@"line"]];
		}
	}
}

// A callback that gets called when a TaskWrapper is launched, allowing us to do any setup
// that is needed from the app side.  This method is implemented as a part of conforming
// to the ProcessController protocol.
- (void)processStarted
{
	self.running = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:GHProcessStarted object:self];
}

// A callback that gets called when a TaskWrapper is completed, allowing us to do any cleanup
// that is needed from the app side.  This method is implemented as a part of conforming
// to the ProcessController protocol.
- (void)processFinished:(int)terminationStatus
{
	self.running = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:GHProcessStopped	object:self];
}


@end
