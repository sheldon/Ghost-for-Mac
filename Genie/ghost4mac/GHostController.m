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

#import "TaskWrapper.h"
#import "GHostController.h"

@implementation GHostController
@synthesize ghostDir;
@synthesize running;

NSString * const GHConsoleOutput = @"GHConsoleOutput";
//NSString * const GHSocketOutput = @"GHSocketOutput";
NSString * const GHProcessStarted = @"GHProcessStarted";
NSString * const GHProcessStopped = @"GHProcessStopped";

static GHostController *sharedController = nil;

+ (GHostController*)sharedController
{
    @synchronized(self) {
        if (sharedController == nil) {
            sharedController = [[[self alloc] init] autorelease];
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

+ (NSString *)applicationSupportFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex: 0] : NSTemporaryDirectory();
	return [basePath stringByAppendingPathComponent: [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*)kCFBundleExecutableKey]];
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
				consoleBuffer = [NSMutableString stringWithCapacity:256];
				self.ghostDir = [[GHostController applicationSupportFolder] stringByAppendingPathComponent: @"ghost"];
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

- (void)startWithConfig:(NSString*)cfg {
	@synchronized(self) {
		//[startButton setTitle:@"Running..."];
		if (ghost!=nil)
			[ghost release];
		NSArray *args = nil;
		BOOL isDir;
		if ([[NSFileManager defaultManager] fileExistsAtPath:cfg isDirectory:&isDir] && !isDir)
			args = [NSArray arrayWithObject:cfg];
			//cfg = @"";
		// Let's allocate memory for and initialize a new TaskWrapper object, passing
		// in ourselves as the controller for this TaskWrapper object, the path
		// to the command-line tool, and the contents of the text field that 
		// displays what the user wants to search on
		ghost=[[TaskWrapper alloc]
			   initWithController:self
			   execpath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent: @"ghost++"]
			   workdir:self.ghostDir
			   environment:[NSDictionary dictionaryWithObjectsAndKeys:
							[[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent: @"lib"] stringByAppendingString:@":/usr/lib"],
							@"DYLD_FALLBACK_LIBRARY_PATH",
							nil]

			   arguments:args
		];
		// kick off the process asynchronously
		[ghost startProcess];
	}
}

- (void)stop {
	@synchronized(self) {
		[ghost stopProcess];
		// Release the memory for this wrapper object
		[ghost release];
		ghost = nil;
	}
}



// This callback is implemented as part of conforming to the ProcessController protocol.
// It will be called whenever there is output from the TaskWrapper.
- (void)appendOutput:(NSString *)output
{
	NSLog(@"%@", output);
	@synchronized(self) {
		output = [consoleBuffer stringByAppendingString:output];
		NSArray *printlines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		int last = [printlines count];
		if ([output hasSuffix:@"\n"]) {
			[consoleBuffer setString:@""];
		}
		else {
			// output does not end with a newline, thus is not complete
			// save the last element in buffer
			last--;
			[consoleBuffer appendString:[printlines lastObject]];
		}
		for(int i=0;i<last;i++) {
			NSString *line = [[printlines objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if ([line length] > 0) {
				[[NSNotificationCenter defaultCenter] postNotificationName:GHConsoleOutput object:self userInfo:[NSDictionary dictionaryWithObject:line forKey:@"line"]];
			}
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
