#import "GHostController.h"
#import "BadgeView.h"

@implementation GHostController
- (IBAction)startStop:(id)sender {
	if (!isRunning) {
    //[startButton setTitle:@"Running..."];
	if (ghost!=nil)
        [ghost release];
	// Let's allocate memory for and initialize a new TaskWrapper object, passing
	// in ourselves as the controller for this TaskWrapper object, the path
	// to the command-line tool, and the contents of the text field that 
	// displays what the user wants to search on
	ghost=[[TaskWrapper alloc]
		   initWithController:self
		   execpath:[[self getDir] stringByAppendingPathComponent: @"ghost++"]
		   workdir:[self getDir]
		   environment:[NSDictionary dictionaryWithObjectsAndKeys: @"../lib:../lib/gcc43:../lib/mysql5/mysql:..:.", @"DYLD_FALLBACK_LIBRARY_PATH", nil]
		   arguments:[NSArray arrayWithObjects: [configSelector title],nil]];
		   
	//[[ghost getProcess] setLaunchPath:[applicationResourcesWrapperPath stringByAppendingString: @"/bin"];
	//[[ghost getProcess] setCurrentDirectoryPath: [applicationResourcesWrapperPath stringByAppendingString: @"/bin/"]];
	//[[ghost getProcess] setArguments:[NSArray arrayWithObject:[configSelector stringValue]]];
	
	
	// kick off the process asynchronously
	[ghost startProcess];
    } else {
		[ghost stopProcess];
		// Release the memory for this wrapper object
		[ghost release];
		ghost=nil;
	}
}

- (id)init
{
	[super init];
	isRunning=NO;
	badge = [[BadgeView alloc] init];
	[[NSApp dockTile] setContentView: badge];
	
	
	NSArray *enumerator  = [[NSFileManager defaultManager] directoryContentsAtPath: [self getDir]];
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
		//NSLog("%s\n" , item);
	}

	//cfgfiles = [[NSMutableArray alloc] initWithArray: enumerator/*[enumerator filterUsingSelector:@selector(hasSuffix:), @".cfg", nil]*/];
		
	//NSLog(cfgfiles);
	
	/*while ((file = [enumerator nextObject])) {
		// do stuff
		NSLog(file);
	}*/
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
    isRunning=YES;
	[startStopButton setLabel:@"Stop"];
	[startStopButton setImage: [NSImage imageNamed: @"NSStopProgressFreestandingTemplate"]];
	[badge setRunning: YES];
    // clear the results
    //[resultsTextField setString:@""];
}

// A callback that gets called when a TaskWrapper is completed, allowing us to do any cleanup
// that is needed from the app side.  This method is implemented as a part of conforming
// to the ProcessController protocol.
- (void)processFinished:(int)terminationStatus
{
    isRunning=NO;
	[badge setRunning: NO];
	[startStopButton setLabel:@"Start"];
	[startStopButton setImage: [NSImage imageNamed: @"NSRightFacingTriangleTemplate"]];
	[self appendOutput:@"GHost++ terminated"];
}

- (NSString*)getDir
{
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"bin"];
}
@end
