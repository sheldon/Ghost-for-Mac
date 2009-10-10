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
#import "RegexKit/RegexKit.h"
#import "TCMPortMapper/TCMPortMapper.h"
#import "GHostSocket.h"
#import "Growl/GrowlApplicationBridge.h"
//#import "PanelStartupController.h"

@implementation UIController
@synthesize lines;

+(void)initialize
{
	NSString *userDefaultsValuesPath;
    NSDictionary *userDefaultsValuesDict;
    //NSDictionary *initialValuesDict;
    //NSArray *resettableUserDefaultsKeys;
	
    // load the default values for the user defaults
    userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
    userDefaultsValuesDict=[NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	
    // set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
	
    // if your application supports resetting a subset of the defaults to
    // factory values, you should set those values
    // in the shared user defaults controller
    //resettableUserDefaultsKeys=[NSArray arrayWithObjects:@"Value1",@"Value2",@"Value3",nil];
    //initialValuesDict=[userDefaultsValuesDict dictionaryWithValuesForKeys:resettableUserDefaultsKeys];
	
    // Set the initial values in the shared user defaults controller
    //[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValuesDict];
}

-(NSRect)newFrameForNewContentView:(NSView *)view {
    NSWindow *window = mainWindow;
    NSRect newFrameRect = [window frameRectForContentRect:[view frame]];
    NSRect oldFrameRect = [window frame];
    NSSize newSize = newFrameRect.size;
	newSize.height += [mainWindow contentBorderThicknessForEdge:NSMinYEdge];
    NSSize oldSize = oldFrameRect.size;
    
    NSRect frame = [window frame];
    frame.size = newSize;
    frame.origin.y -= (newSize.height - oldSize.height);
    
    return frame;
}

-(NSView *)viewForTag:(int)tag {
    NSView *view = nil;
    switch(tag) {
		case 0: view = [consoleView view]; break;
		case 1: view = [chatView view]; break;
		default: view = [consoleView view]; break;
    }
    return view;
}


-(IBAction)switchView:(id)sender {
	int tag = [sender selectedSegment];
	NSView *view = [self viewForTag:tag];
	NSView *previousView = [self viewForTag: currentViewTag];
	currentViewTag = tag;
	
	NSRect newWindowFrame = [mainWindow frameRectForContentRect:[view frame]];
	newWindowFrame.size.height += [mainWindow contentBorderThicknessForEdge:NSMinYEdge];
	
	NSRect frame = [mainView frame];
	frame.origin.y -= [mainWindow contentBorderThicknessForEdge:NSMinYEdge];
	[view setFrame:frame];
	
	[mainView replaceSubview:previousView with:view];
	newWindowFrame.origin = [mainWindow frame].origin;
	newWindowFrame.origin.y -= newWindowFrame.size.height - [mainWindow frame].size.height;
	[mainWindow setFrame:newWindowFrame display:YES animate:YES];
}


-(void)awakeFromNib {
	//[[mainWindow contentView] setWantsLayer:YES];
	//[mainView setWantsLayer:YES];
	[mainWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
	[mainWindow setContentBorderThickness: 24.0 forEdge: NSMinYEdge];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(doTerminate:)
	 name:NSApplicationWillTerminateNotification
	 object:NSApp];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processStarted:) name:GHProcessStarted object:ghost];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processStopped:) name:GHProcessStopped object:ghost];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appendOutputNotify:) name:GHConsoleOutput object:ghost];
	TCMPortMapper *pm = [TCMPortMapper sharedInstance];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(portMapperDidStartWork:) 
												 name:TCMPortMapperDidStartWorkNotification object:pm];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(portMapperDidFinishWork:)
												 name:TCMPortMapperDidFinishWorkNotification object:pm];
	
	[badge bind:@"running" toObject:ghost withKeyPath:@"running" options:nil];
	
	// set badge as dock icon
	[[NSApp dockTile] setContentView: badge];
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:generalController, configController, mapController/*, msgController*/, nil]];
	// load views so they get instanciated and populated
	//[configController loadView];
	//[[configController view] init];
	[chatView loadView];
	NSRect newWindowFrame = [mainWindow frameRectForContentRect:[[consoleView view] frame]];
	newWindowFrame.size.height += [mainWindow contentBorderThicknessForEdge:NSMinYEdge];
	newWindowFrame.origin = [mainWindow frame].origin;
	newWindowFrame.origin.y -= newWindowFrame.size.height - [mainWindow frame].size.height;
	NSRect oldRect = [mainWindow frame];
	[mainWindow setFrame:newWindowFrame display:NO animate:NO];
	[mainView addSubview:[consoleView view]];
	[mainWindow setFrame:oldRect display:NO animate:NO];
	
	BOOL enableUPnP = [[[userDefaultsController values] valueForKey:@"enableUPnPPortMapping"] boolValue];
	if (enableUPnP)
	{
		[portMapProgress setHidden:YES];
		[portMapStatus setHidden:NO];
		[portMapText setHidden:NO];
	}
	else
	{
		[portMapProgress setHidden:NO];
		[portMapStatus setHidden:NO];
		[portMapText setHidden:NO];
	}

	//[ rearrangeObjects];
	//[self appendOutput:@"[GENIE] Genie started"];
	//[LogEntry logEntryWithText:@"Genie started" sender:@"GENIE" date:[NSDate date] image:[NSImage imageNamed:@"ghost.png"]]
}


+ (NSString *)applicationSupportFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex: 0] : NSTemporaryDirectory();
	return [basePath stringByAppendingPathComponent: [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*)kCFBundleExecutableKey]];
}

- (IBAction)startStop:(id)sender
{
	//ghost.config = [[UIController getConfigDir] stringByAppendingPathComponent:[configSelector title]];
	if (ghost.running)
		[ghost stop];
	else {
		if ([configSelector selectedItem])
			[ghost startWithConfig:[[UIController getConfigDir] stringByAppendingPathComponent:[configSelector title]]];
		else
			[ghost startWithConfig:[[UIController getConfigDir] stringByAppendingPathComponent:@"ghost.cfg"]];
	}
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





- (IBAction)showPreferences:(id)sender {
	[[MBPreferencesController sharedController] showWindow:sender];
}

- (void)portMapperDidStartWork:(NSNotification *)aNotification {
    //[O_portStatusProgressIndicator startAnimation:self];
    //[O_portStatusImageView setHidden:YES];
    //[O_portStatusTextField setStringValue:@"Checking port status..."];
	NSLog(@"Checking port status...");
}

- (void)portMapperDidFinishWork:(NSNotification *)aNotification {
    [portMapProgress stopAnimation:self];
    TCMPortMapper *pm = [TCMPortMapper sharedInstance];
    // since we only have one mapping this is fine
    TCMPortMapping *mapping = [[pm portMappings] anyObject];
    if ([mapping mappingStatus]==TCMPortMappingStatusMapped) {
        /*[O_portStatusImageView setImage:[NSImage imageNamed:@"URLIconOK"]];
        [O_portStatusTextField setStringValue:
		 [NSString stringWithFormat:@"see://%@:%d",
		  [pm externalIPAddress],[mapping externalPort]]];*/
		[portMapText setStringValue:@"Port mapping successful!"];
		[portMapStatus setImage:[NSImage imageNamed:@"GreenDot.png"]];
    } else {
		[portMapText setStringValue:@"Port mapping failed!"];
		[portMapStatus setImage:[NSImage imageNamed:@"RedDot.png"]];
        /*[O_portStatusImageView setImage:[NSImage imageNamed:@"URLIconNotOK"]];
        [O_portStatusTextField setStringValue:@"No public mapping."];*/
    }
	
	[portMapProgress setHidden:YES];
	[portMapStatus setHidden:NO];
}

- (void)gotHostPortInfo:(NSInteger)port
{
	//BOOL enableUPnP = [[theDefaultsController values] valueForKey:@"userName"];
	BOOL enableUPnP = [[[userDefaultsController values] valueForKey:@"enableUPnPPortMapping"] boolValue];
	if (!enableUPnP)
		return;
	
	TCMPortMapper *pm = [TCMPortMapper sharedInstance];
	[pm addPortMapping:
	 [TCMPortMapping portMappingWithLocalPort:port 
						  desiredExternalPort:port 
							transportProtocol:TCMPortMappingTransportProtocolTCP
									 userInfo:nil]];
	[portMapProgress startAnimation:self];
	[portMapStatus setHidden:YES];
	[portMapProgress setHidden:NO];
	[portMapText setStringValue:@"Mapping port via UPnP..."];
	[pm start];
}

- (void)ghostStarted:(NSString *)version
{
	NSString *startupMap = [[NSUserDefaults standardUserDefaults] valueForKey:@"startupMap"];
	if (startupMap)
		[[GHostSocket sharedSocket] sendCommand:[@"map " stringByAppendingString:startupMap]];
	[ghostVersion setStringValue:[@"GHost++ " stringByAppendingString:version]];
	[ghostVersion setHidden:NO];
}

- (void)appendOutput:(NSString *)output
{
	const NSString* hostExpression = @"^\\[GHOST\\] using bot_hostport \\[(\\d+)\\]";
	const NSString* ghostStarted = @"^\\[GHOST\\] GHost\\+\\+ Version (\\d+\\.\\d+)";
	const NSString* rconStarted = @"^\\[RCON\\] Listening at \\[.*?\\] on port \\[(\\d+)\\]";
	NSString *portString;
	NSString *capture1;
	if ([output getCapturesWithRegexAndReferences:rconStarted, @"$1", &portString, nil]) {
		NSInteger port = [portString intValue];
		[[GHostSocket sharedSocket] initWithPort:port];
	}
	else if ([output getCapturesWithRegexAndReferences:hostExpression, @"$1", &portString, nil]) {
		NSInteger port = [portString intValue];
		NSLog(@"GOT PORT: %d", port);
		[self gotHostPortInfo:port];
	}
	else if ([output getCapturesWithRegexAndReferences:ghostStarted, @"$1", &capture1, nil]) {
		NSLog(@"GOT GHOST VERSION: %@", capture1);
		[self ghostStarted:capture1];
	}
	[consoleView addCoreOutput:output];
	[chatView parseConsoleOutput:output];
}

- (void)appendOutputNotify:(NSNotification*)note
{
	[self appendOutput:[[note userInfo] objectForKey:@"line"]];
}

+ (NSString *)getConfigDir {
	return [[self applicationSupportFolder] stringByAppendingPathComponent: @"config"];
}

- (void)processStarted:(NSNotification*)note {
	[startStopButton setLabel:@"Stop"];
	[startStopButton setImage: [NSImage imageNamed: @"NSStopProgressFreestandingTemplate"]];
	//[[GHostSocket sharedSocket] initWithPort:6969];
}

- (void)processStopped:(NSNotification*)note {
	[startStopButton setLabel:@"Start"];
	[startStopButton setImage: [NSImage imageNamed: @"NSRightFacingTriangleTemplate"]];
	[self appendOutput:@"GHost++ terminated\n"];
}

- (id)init
{
	if ([super init])
	{
		ghost = [GHostController sharedController];
		//lines = [NSMutableArray arrayWithObject:[LogEntry logEntryWithText:@"Genie started" sender:@"GENIE" date:[NSDate date] image:[NSImage imageNamed:@"ghost.png"]]];
		lines = [NSMutableArray array];
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	return self;
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
	[self performSelectorOnMainThread:@selector(doStuffOnMainGUIThread:)
                           withObject:nil
                        waitUntilDone:NO];
	
}

- (void)copyFilesAsync:(id)arg {
	/*check for necessary files*/
	NSError *error;
	NSString *appSupportDir = [UIController applicationSupportFolder];
	NSString *resDir = [[NSBundle mainBundle] resourcePath];
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm contentsOfDirectoryAtPath:[UIController getConfigDir] error:nil] == nil || [[fm contentsOfDirectoryAtPath:[UIController getConfigDir] error:nil] count] < 1) {
		[fm createDirectoryAtPath:[UIController getConfigDir] withIntermediateDirectories:YES attributes:nil error:nil];
		[fm copyItemAtPath:[[resDir stringByAppendingPathComponent:@"defaults"] stringByAppendingPathComponent:@"ghost.cfg"] toPath:[[UIController getConfigDir] stringByAppendingPathComponent:@"ghost.cfg"] error:nil];
		[configController reloadConfigList];
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
	
	//NSMutableArray *requiredFiles = [NSMutableArray arrayWithObjects:@"war3.exe",@"Storm.dll",@"game.dll",@"War3Patch.mpq",nil];
	
	[NSApp endSheet:progressPanel.window returnCode:0];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)item {
    //if ([item tag] == 1337) return [item isEnabled];
    //else return YES;
	return [item isEnabled];
}

- (void)doTerminate:(NSNotification *)note
{
	[ghost stop];
	[[TCMPortMapper sharedInstance] stopBlocking];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	BOOL startHidden = [[[userDefaultsController values] valueForKey:@"startHidden"] boolValue];
	if (!startHidden)
		[mainWindow orderFront: mainWindow];
	[progressPanel showSheet:mainWindow];
	[configController reloadConfigList];
	BOOL startGHost = [[[userDefaultsController values] valueForKey:@"runGHostOnStartup"] boolValue];
    if (startGHost)
		[ghost startWithConfig:[[UIController getConfigDir] stringByAppendingPathComponent:[configSelector title]]];
	//[progressBar startAnimation:self];
	//NSLog("MainWindow: %s", mainWindow);
	
	//[self performSelectorInBackground:@selector(copyFilesAsync:) withObject:nil];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if (!ghost.running || NSRunAlertPanel(@"Application Exit", @"GHost++ is still running, are you sure you want to exit?", @"No", @"Yes", nil) == NSAlertAlternateReturn)
	{
		return YES;
	}
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
