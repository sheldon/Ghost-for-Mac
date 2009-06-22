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
#import "LogEntry.h"
#import "ConfigController.h"

@implementation GHostController
@synthesize maps;
@synthesize running;

@synthesize lines;
+ (NSString *)applicationSupportFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex: 0] : NSTemporaryDirectory();
	return [basePath stringByAppendingPathComponent: [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*)kCFBundleExecutableKey]];
}


+ (NSString *)getGhostDir {
	return [[GHostController applicationSupportFolder] stringByAppendingPathComponent: @"ghost"];		
}

+ (NSString *)getConfigDir {
	return [[GHostController applicationSupportFolder] stringByAppendingPathComponent: @"config"];		
}

+ (NSString *)getLibDir {
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
		   execpath:[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"bin"] stringByAppendingPathComponent: @"ghost++"]
		   workdir:[GHostController getGhostDir]
		   environment:[NSDictionary dictionaryWithObjectsAndKeys: [GHostController getLibDir], @"DYLD_FALLBACK_LIBRARY_PATH", nil]
		   //TODO: set argument for config file
		   arguments:[NSArray arrayWithObjects: [[GHostController getConfigDir] stringByAppendingPathComponent:[configSelector title]],nil]];
	
	// kick off the process asynchronously
	[ghost startProcess];
	
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [lines count];
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(int)row
{
	NSString *col = [tableColumn identifier];
	LogEntry *log = [lines objectAtIndex:row];
	if ([col isEqualToString:@"image"])
		return [log image];
	if ([col isEqualToString:@"text"])
		return [log text];
	if ([col isEqualToString:@"time"])
		//return @"test";
		return [log date];
	if ([col isEqualToString:@"sender"])
		return [log sender];
    return @"";
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

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
	[self performSelectorOnMainThread:@selector(doStuffOnMainGUIThread:)
                           withObject:nil
                        waitUntilDone:NO];
	
}

- (void)doStuffOnMainGUIThread:(id)arg {
	BOOL startGHost = ([[NSUserDefaults standardUserDefaults] integerForKey:@"runGHostOnStartup"] == 1);
    if (startGHost)
		[self start];
}

- (void)copyFilesAsync:(id)arg {
	/*check for necessary files*/
	NSError *error;
	NSString *appSupportDir = [GHostController applicationSupportFolder];
	NSString *resDir = [[NSBundle mainBundle] resourcePath];
	/*NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:[[resDir stringByAppendingPathComponent:@"bin"] stringByAppendingPathComponent:@"version.plist"]];
	
	if (prefs != nil) {
		//TODO: check GHost core version?
		//[prefs objectForKey:@"Client"];
	} else {
		NSLog(@"Could not read version.plist!");
	}*/
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm contentsOfDirectoryAtPath:[GHostController getConfigDir] error:nil] == nil) {
		[fm createDirectoryAtPath:[GHostController getConfigDir] withIntermediateDirectories:YES attributes:nil error:nil];
		[fm copyItemAtPath:[[resDir stringByAppendingPathComponent:@"defaults"] stringByAppendingPathComponent:@"ghost.cfg"] toPath:[[GHostController getConfigDir] stringByAppendingPathComponent:@"ghost.cfg"] error:nil];
	}
	// check core directory
	if ([fm contentsOfDirectoryAtPath:[GHostController getGhostDir] error:nil] == nil) {
		// create core directory
		[fm createDirectoryAtPath:[GHostController getGhostDir] withIntermediateDirectories:YES attributes:nil error:nil];
		NSString *from = [NSString pathWithComponents:[NSArray arrayWithObjects:resDir,@"defaults",@"ghost",nil]];
		NSString *to = [GHostController getGhostDir];
		NSArray *miscfiles  = [[NSFileManager defaultManager] directoryContentsAtPath: from];
		// copy required files
		for(NSString* file in miscfiles) {
			if (![fm copyItemAtPath:[from stringByAppendingPathComponent:file] toPath:[to stringByAppendingPathComponent:file] error:&error])
				NSLog(@"Error: %@\n\tTrying to copy file '%@' from '%@' to '%@'", error, file, from, to);
		}
	}
	/* create links for dylibs */
	NSDictionary *lnFiles = [NSDictionary dictionaryWithObjectsAndKeys:	@"libgmp.3.4.4.dylib",@"libgmp.3.dylib",@"libmysqlclient.16.0.0.dylib",@"libmysqlclient.16.dylib",nil];
	for (NSString* key in lnFiles) {
		if (![fm createSymbolicLinkAtPath:[[GHostController getLibDir] stringByAppendingPathComponent:key] withDestinationPath:[[GHostController getLibDir] stringByAppendingPathComponent:[lnFiles objectForKey:key]] error:&error])
			NSLog(@"Error: %@\n\tTrying linking '%@' -> '%@'", error, [lnFiles objectForKey:key], key);
	}
	
	
	NSMutableArray *requiredFiles = [NSMutableArray arrayWithObjects:@"war3.exe",@"Storm.dll",@"game.dll",@"War3Patch.mpq",nil];
	NSMutableArray *filesNotFound = [NSMutableArray arrayWithArray:requiredFiles];
	
	// create directory to hold warcraft 3 windows files
	NSString *war3dir = [appSupportDir stringByAppendingPathComponent:@"war3files"];
	[fm createDirectoryAtPath:war3dir withIntermediateDirectories:YES attributes:nil error:nil];
	NSArray *existingFiles = [fm contentsOfDirectoryAtPath:war3dir error:nil];
	for (NSString *file in requiredFiles) {
		if ([existingFiles containsObject:file])
			[filesNotFound removeObject:file];
	}
	
	if ([filesNotFound count] > 0 && NSRunAlertPanelRelativeToWindow(@"Required files missing!",
																	 @"Some files that are required to run GHost have not been installed yet.\nThe files missing are:\n%@\nDo you want to install them now?",
																	 @"Yes", @"No", nil,progressPanel, filesNotFound) == NSAlertDefaultReturn) {
		[requiredFiles setArray:filesNotFound];
		// Create the File Open Dialog class.
		NSOpenPanel* openDlg = [NSOpenPanel openPanel];
		[openDlg setTitle:@"Select Windows Wacraft 3 Installation"];
		// Disable the selection of files in the dialog.
		[openDlg setCanChooseFiles:NO];
		
		[openDlg setAllowsMultipleSelection:NO];
		
		//[openDlg setAllowedFileTypes:[NSArray arrayWithArray:requiredFiles]];
		
		// Enable the selection of directories in the dialog.
		[openDlg setCanChooseDirectories:YES];
		
		BOOL abort = YES;
		// retry selection if required files are missing
		do {
			// Display the dialog.  If the OK button was pressed,
			// process the files.
			if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
			{
				// Get an array containing the full filenames of all
				// files and directories selected.
				NSArray* files = [fm contentsOfDirectoryAtPath:[openDlg filename] error:nil];
				
				// Loop through all the files and process them.
				for( NSString *file in requiredFiles )
				{
					if ([files containsObject:file])
						[filesNotFound removeObject:file];
				}
				// copy required files
				for(NSString* file in requiredFiles) {
					if (![filesNotFound containsObject:file] && ![fm copyItemAtPath:[[openDlg filename] stringByAppendingPathComponent:file] toPath:[war3dir stringByAppendingPathComponent:file] error:&error]) {
						NSAlert *errorDlg = [NSAlert alertWithError:error];
						[errorDlg runModal];
					}
				}
				
				if ([filesNotFound count] > 0) {
					NSAlert *alert = [NSAlert alertWithMessageText:@"Missing files!" defaultButton:@"Retry" alternateButton:@"Abort" otherButton:nil informativeTextWithFormat:@"Some required files were not present at the location you specified.\nThe missing files are:\n%@",filesNotFound];
					NSInteger result = [alert runModal];
					if (result == NSAlertDefaultReturn) {
						// User didn't click ok
						abort = NO;
					}
				}
			}
		} while (!abort);
	}
	
	[NSApp endSheet:progressPanel returnCode:0];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	BOOL startHidden = ([[NSUserDefaults standardUserDefaults] integerForKey:@"startHidden"] == 1);
	if (!startHidden)
		[mainWindow orderFront: mainWindow];
	[progressBar startAnimation:self];
	[NSApp beginSheet: progressPanel
	   modalForWindow: mainWindow
		modalDelegate: self
	   didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo: nil];
	[self performSelectorInBackground:@selector(copyFilesAsync:) withObject:nil];
	[badge bind:@"running" toObject:self withKeyPath:@"running" options:nil];
	// set badge as dock icon
	[[NSApp dockTile] setContentView: badge];
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:generalController, configController, nil]];
	//[mainWindow setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
	//[mainWindow setContentBorderThickness: 26.0 forEdge: NSMinYEdge];
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
	return YES;
}

- (id)init
{
	[super init];
	self.running = NO;
	cmdSock = [[AsyncUdpSocket alloc] initWithDelegate:self];
	[cmdSock connectToHost:@"localhost" onPort:6969 error:nil];
	[cmdSock receiveWithTimeout:-1 tag:0];
	lines = [NSMutableArray arrayWithObject:[LogEntry logEntryWithText:@"Genie started" sender:@"GENIE" date:[NSDate date] image:[NSImage imageNamed:@"ghost.png"]]];
    //BOOL fileExists = [fm fileExistsAtPath:someWhere];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(doTerminate:)
	 name:NSApplicationWillTerminateNotification
	 object:NSApp];
		
	return self;
}

- (void)sendCommand:(NSString*)cmd {
	[cmdSock sendData:[cmd dataUsingEncoding:NSASCIIStringEncoding] withTimeout:30 tag:0];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
	//NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 1)];
	NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		if ([msg isEqualToString:@"PING"])
			[self sendCommand:@"\n"];
		// don't print this, we get it directly from the process anyway
		//[self appendOutput:msg];
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
	NSInteger count = [[listController arrangedObjects] count];
	
	NSArray *printlines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	for(NSString* line in printlines) {
		line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([line length] > 0)
			[listController addObject:[LogEntry logEntryWithLine:line]];
	}
	
	NSInteger newcount = [[listController arrangedObjects] count];
	if ([autoScrollCheckbox state] == NSOnState && newcount != count) {
		[consoleTable scrollRowToVisible:newcount - 1];
	}
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
