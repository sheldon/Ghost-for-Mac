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

#import "UIController.h"
#import	"LogEntry.h"
#import "MBPreferencesController.h"
#import "ghost4mac/GHostController.h"

@implementation UIController

@synthesize lines;

- (IBAction)startStop:(id)sender
{
	//ghost.config = [[UIController getConfigDir] stringByAppendingPathComponent:[configSelector title]];
	if (ghost.running)
		[ghost stop];
	else
		[ghost startWithConfig:[[UIController getConfigDir] stringByAppendingPathComponent:[configSelector title]]];
}
- (IBAction)restart:(id)sender
{
	[ghost stop];
	[ghost startWithConfig:[[UIController getConfigDir] stringByAppendingPathComponent:[configSelector title]]];
}

- (IBAction)selectFont:(id)sender {
    
}

// handle enter event from command input
- (BOOL)control: (NSControl *)control textView:(NSTextView *)textView doCommandBySelector: (SEL)commandSelector {
	//NSLog(@"entered control area = %@",NSStringFromSelector(commandSelector));
	if (commandSelector == @selector(insertTab:)) {
		// pressed key was tab
		NSLog(@"TAB pressed!");
		return YES;
	}
	return NO;
}

- (IBAction)sendCommand:(id)sender {
	NSLog([sender stringValue]);
	[ghost sendCommand:[sender stringValue]];
	[sender setStringValue:@""];
}



- (IBAction)showPreferences:(id)sender {
	[[MBPreferencesController sharedController] showWindow:sender];
}

-(void)copyToClipboard:(NSString*)str
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
    [pb declareTypes:types owner:self];
    [pb setString: str forType:NSStringPboardType];
}

- (IBAction)copyLines:(id)sender {
	NSMutableString* output = [NSMutableString string];
	for (LogEntry *e in [listController selectedObjects]) {
		[output appendFormat:@"[%@ %@] %@\n",e.sender,[e.date descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],e.text];
	}
	[self copyToClipboard:output];
}

- (void)appendOutput:(NSString *)output
{
	//NSLog(output);
	NSInteger count = [[listController arrangedObjects] count];
	[listController addObject:[LogEntry logEntryWithLine:output]];
	
	NSInteger newcount = [[listController arrangedObjects] count];
	if ([autoScrollCheckbox state] == NSOnState && newcount != count) {
		[consoleTable scrollRowToVisible:newcount - 1];
	}
}

- (void)appendOutputNotify:(NSNotification*)note
{
	[self appendOutput:[[note userInfo] objectForKey:@"line"]];
}

+ (NSString *)applicationSupportFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex: 0] : NSTemporaryDirectory();
	return [basePath stringByAppendingPathComponent: [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*)kCFBundleExecutableKey]];
}

+ (NSString *)getConfigDir {
	return [[self applicationSupportFolder] stringByAppendingPathComponent: @"config"];
}

- (void)processStarted:(NSNotification*)note {
	[startStopButton setLabel:@"Stop"];
	[startStopButton setImage: [NSImage imageNamed: @"NSStopProgressFreestandingTemplate"]];
}

- (void)processStopped:(NSNotification*)note {
	[startStopButton setLabel:@"Start"];
	[startStopButton setImage: [NSImage imageNamed: @"NSRightFacingTriangleTemplate"]];
	[self appendOutput:@"GHost++ terminated\n"];
}

- (id)init
{
	[super init];
	ghost = [GHostController sharedController];
	ghost.ghostDir = [[UIController applicationSupportFolder] stringByAppendingPathComponent: @"ghost"];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processStarted:) name:GHProcessStarted object:ghost];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processStopped:) name:GHProcessStopped object:ghost];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appendOutputNotify:) name:GHConsoleOutput object:ghost];
	lines = [NSMutableArray arrayWithObject:[LogEntry logEntryWithText:@"Genie started" sender:@"GENIE" date:[NSDate date] image:[NSImage imageNamed:@"ghost.png"]]];
	return self;
}

- (void)copyFilesAsync:(id)arg {
	/*check for necessary files*/
	NSError *error;
	NSString *appSupportDir = [[self class] applicationSupportFolder];
	NSString *resDir = [[NSBundle mainBundle] resourcePath];
	/*NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:[[resDir stringByAppendingPathComponent:@"bin"] stringByAppendingPathComponent:@"version.plist"]];
	 
	 if (prefs != nil) {
	 //TODO: check GHost core version?
	 //[prefs objectForKey:@"Client"];
	 } else {
	 NSLog(@"Could not read version.plist!");
	 }*/
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm contentsOfDirectoryAtPath:ghost.ghostDir error:nil] == nil) {
		[fm createDirectoryAtPath:ghost.ghostDir withIntermediateDirectories:YES attributes:nil error:nil];
		[fm copyItemAtPath:[[resDir stringByAppendingPathComponent:@"defaults"] stringByAppendingPathComponent:@"ghost.cfg"] toPath:[ghost.ghostDir stringByAppendingPathComponent:@"ghost.cfg"] error:nil];
	}
	// check core directory
	if ([fm contentsOfDirectoryAtPath:ghost.ghostDir error:nil] == nil) {
		// create core directory
		[fm createDirectoryAtPath:ghost.ghostDir withIntermediateDirectories:YES attributes:nil error:nil];
		NSString *from = [NSString pathWithComponents:[NSArray arrayWithObjects:resDir,@"defaults",@"ghost",nil]];
		NSString *to = [ghost.ghostDir retain];
		NSArray *miscfiles  = [[NSFileManager defaultManager] directoryContentsAtPath: from];
		// copy required files
		for(NSString* file in miscfiles) {
			if (![fm copyItemAtPath:[from stringByAppendingPathComponent:file] toPath:[to stringByAppendingPathComponent:file] error:&error])
				NSLog(@"Error: %@\n\tTrying to copy file '%@' from '%@' to '%@'", error, file, from, to);
		}
	}
	/* create links for dylibs */
	/*NSDictionary *lnFiles = [NSDictionary dictionaryWithObjectsAndKeys:	@"libgmp.3.4.4.dylib",@"libgmp.3.dylib",@"libmysqlclient.16.0.0.dylib",@"libmysqlclient.16.dylib",nil];
	for (NSString* key in lnFiles) {
		if (![fm createSymbolicLinkAtPath:[[GHostController getLibDir] stringByAppendingPathComponent:key] withDestinationPath:[[GHostController getLibDir] stringByAppendingPathComponent:[lnFiles objectForKey:key]] error:&error])
			NSLog(@"Error: %@\n\tTrying linking '%@' -> '%@'", error, [lnFiles objectForKey:key], key);
	}*/
	
	
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
	/*[NSApp beginSheet: progressPanel
	   modalForWindow: mainWindow
		modalDelegate: self
	   didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo: nil];*/
	//[self performSelectorInBackground:@selector(copyFilesAsync:) withObject:nil];
	[badge bind:@"running" toObject:ghost withKeyPath:@"running" options:nil];
	// set badge as dock icon
	[[NSApp dockTile] setContentView: badge];
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:generalController, configController, nil]];
	//[mainWindow setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
	//[mainWindow setContentBorderThickness: 26.0 forEdge: NSMinYEdge];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if (!ghost.running || NSRunAlertPanel(@"Application Exit", @"GHost++ is still running, are you sure you want to exit?", @"No", @"Yes", nil) == NSAlertAlternateReturn)
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
@end
