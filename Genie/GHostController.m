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
#import "BadgeView.h"

@implementation GHostController
@synthesize running;
- (NSString *)applicationSupportFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex: 0] : NSTemporaryDirectory();
	return [basePath stringByAppendingPathComponent: [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*)kCFBundleExecutableKey]];
}

- (NSString *)ghostDir {
	return [[self applicationSupportFolder] stringByAppendingPathComponent: @"ghost"];
}

- (NSString *)configDir {
	return [[self applicationSupportFolder] stringByAppendingPathComponent: @"configs"];
}

- (NSString *)libDir {
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"lib"];
}

- (void)start {
	//[startButton setTitle:@"Running..."];
	if (ghost!=nil)
        [ghost release];
	// Let's allocate memory for and initialize a new TaskWrapper object, passing
	// in ourselves as the controller for this TaskWrapper object, the path
	// to the command-line tool, and the contents of the text field that 
	// displays what the user wants to search on
	ghost=[[TaskWrapper alloc]
		   initWithController:self
		   execpath:[[self ghostDir] stringByAppendingPathComponent: @"ghost++"]
		   workdir:[self ghostDir]
		   environment:[NSDictionary dictionaryWithObjectsAndKeys: [self libDir], @"DYLD_FALLBACK_LIBRARY_PATH", nil]
		   //TODO: set argument for config file
		   arguments:[NSArray arrayWithObjects: [configSelector title],nil]];
	
	// kick off the process asynchronously
	[ghost startProcess];
	
}
- (void)stop {
	[ghost stopProcess];
	// Release the memory for this wrapper object
	[ghost release];
	ghost=nil;
}
- (IBAction)restart:(id)sender {
	[self stop];
	[self start];
}



- (IBAction)startStop:(id)sender {
	if (running) {
			[self stop];
        } else {
			[self start];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[badge bind:@"running" toObject:self withKeyPath:@"running" options:nil];
	// set badge as dock icon
	[[NSApp dockTile] setContentView: badge];
	if ([[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"runGHostOnStartup"])
		[self start];
}

- (void) dealloc
{
	[self stop];
    [badge release];
    [super dealloc];
}



- (void)doTerminate:(NSNotification *)note
{
	[self stop];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if (!self.running || NSRunAlertPanel(@"Application Exit", @"GHost++ is still running, are you sure you want to exit?", @"No", @"Yes", nil) == NSAlertAlternateReturn)
		return YES;
	else
		return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    if (![NSApp keyWindow]) {
		// show main window
		[mainWindow orderFront: mainWindow];
	}
    return YES;
}

- (BOOL)windowShouldClose:(id)window
{
	if (window == mainWindow) {
		// hide if main window
		[mainWindow orderOut:window];
		return NO;
	}
	return NO;
}

- (id)init
{
	[super init];
	self.running = NO;
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(doTerminate:)
	 name:NSApplicationWillTerminateNotification
	 object:NSApp];
		
	NSArray *enumerator  = [[NSFileManager defaultManager] directoryContentsAtPath: [self configDir]];
	cfgfiles = [[NSMutableArray alloc] init];
	int i;
	int pathcount;
	pathcount = [enumerator count];
	
	NSLog(@"pathcount %d", pathcount);
	
	for(i = 0; i < pathcount; i++)
	{
		NSString *item = [enumerator objectAtIndex:i];
		NSLog(@"%@ - %@", item, [[item pathExtension] lowercaseString]);
		if ([[item pathExtension] caseInsensitiveCompare: @"cfg"] == NSOrderedSame)
			[cfgfiles addObject: item];
	}
	return self;
}


// This callback is implemented as part of conforming to the ProcessController protocol.
// It will be called whenever there is output from the TaskWrapper.
- (void)appendOutput:(NSString *)output
{
    // add the string (a chunk of the results from locate) to the NSTextView's
    // backing store, in the form of an attributed string
    [[logView textStorage] appendAttributedString: [[[NSAttributedString alloc]
															  initWithString: output] autorelease]];
    // setup a selector to be called the next time through the event loop to scroll
    // the view to the just pasted text.  We don't want to scroll right now,
    // because of a bug in Mac OS X version 10.1 that causes scrolling in the context
    // of a text storage update to starve the app of events
	if ([autoScrollCheckbox state] == NSOnState)
		[self performSelector:@selector(scrollToVisible:) withObject:nil afterDelay:0.0];
}

// This routine is called after adding new results to the text view's backing store.
// We now need to scroll the NSScrollView in which the NSTextView sits to the part
// that we just added at the end
- (void)scrollToVisible:(id)ignore {
    [logView scrollRangeToVisible:NSMakeRange([[logView string] length], 0)];
}

// A callback that gets called when a TaskWrapper is launched, allowing us to do any setup
// that is needed from the app side.  This method is implemented as a part of conforming
// to the ProcessController protocol.
- (void)processStarted
{
	self.running = YES;
	[startStopButton setLabel:@"Stop"];
	[startStopButton setImage: [NSImage imageNamed: @"NSStopProgressFreestandingTemplate"]];
}

// A callback that gets called when a TaskWrapper is completed, allowing us to do any cleanup
// that is needed from the app side.  This method is implemented as a part of conforming
// to the ProcessController protocol.
- (void)processFinished:(int)terminationStatus
{
	self.running = NO;
	[startStopButton setLabel:@"Start"];
	[startStopButton setImage: [NSImage imageNamed: @"NSRightFacingTriangleTemplate"]];
	[self appendOutput:@"GHost++ terminated\n"];
}

/*- (NSString*)getDir
{
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"bin"];
}*/
@end
