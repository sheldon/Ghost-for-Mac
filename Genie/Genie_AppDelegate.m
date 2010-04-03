/*	Genie_AppDelegate.m
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 01.01.10
 *
 *	Genie is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	Genie is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 * 	You should have received a copy of the GNU General Public License
 * 	along with Genie.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Genie_AppDelegate.h"
#import "ConfigureLocalBotWindowController.h"
#import "ConfigureAdminGameWindowController.h"
#import "ShowLocalBotViewController.h"
#import "ShowAdminGameViewController.h"
#import "FileImportWindowController.h"
#import "MBPreferencesController.h"
#import "PreferenceMapsController.h"
#import "PreferenceGeneralController.h"
#import "TCMPortMapper/TCMPortMapper.h"
#import "UKKQueue.h"
#import "GMapFile.h"
#import "Bot.h"
#import "BotLocal.h"
#import "BotAdminGame.h"

@implementation Genie_AppDelegate

@synthesize window;
@synthesize botViewController;

#pragma mark Maps
- (NSString*)mapDir
{
	return [[self applicationSupportDirectory] stringByAppendingPathComponent:@"Warcraft III Maps"];
}
- (void)refreshMaps
{
	NSString *mapDir = [self mapDir];
	NSMutableArray *mapFileNames  = [NSMutableArray arrayWithCapacity:5];
	
	NSString *file;
	
	NSDirectoryEnumerator *dirEnum = 
	[[NSFileManager defaultManager] enumeratorAtPath:mapDir];
	NSArray *mapExtensions = [NSArray arrayWithObjects:@"w3m",@"w3x",nil];
	while (file = [dirEnum nextObject]) {
		if ([mapExtensions containsObject:[file pathExtension]]) {
			[mapFileNames addObject:file];
		}
	}
	
	NSFetchRequest *frq = [[NSFetchRequest alloc] init];
	[frq setEntity:[NSEntityDescription entityForName:@"GMapFile" inManagedObjectContext:self.managedObjectContext]];
	NSArray *existing = [self.managedObjectContext executeFetchRequest:frq error:nil];
	[frq release];
	
	NSEnumerator *mapFileEnum = [existing objectEnumerator];
	GMapFile *curMapFile;
	while (curMapFile = [mapFileEnum nextObject]) {
		if (![mapFileNames containsObject:[curMapFile path]])
		{
			[self.managedObjectContext deleteObject:curMapFile];
		}
		else
			[mapFileNames removeObject:[curMapFile path]];
	}
	
	/*for (int i=0;i<[existing count];i++)
	{
		NSString *filename = [[existing objectAtIndex:i] path];
		if (![configs containsObject:filename])
		{
			[self.managedObjectContext deleteObject:[existing objectAtIndex:i]];
		}
		[configs removeObject:filename];
	}*/

	for(NSString *cfg in mapFileNames)
	{
		// add MO
		GMapFile *file = [NSEntityDescription insertNewObjectForEntityForName:@"GMapFile"
													   inManagedObjectContext:self.managedObjectContext];
		file.path = cfg;
	}
}

- (void)fsHandler:(NSNotification*)msg
{
	[self refreshMaps];
}

- (IBAction)loadMapButtonClicked:(id)sender
{
	NSLog(@"Map: %@", [sender description]);
	/*BOOL pullsDown = NO;
	NSMenu *menu = [[NSMenu alloc] init];
    [menu insertItemWithTitle:@"add"
                       action:@selector(add:)
                keyEquivalent:@""
                      atIndex:0];
	
	NSRect frame = [[sender view] frame];
    frame.origin.x = 0.0;
    frame.origin.y = 0.0;
	
    if (pullsDown) [menu insertItemWithTitle:@"" action:NULL keyEquivalent:@"" atIndex:0];
	
    NSPopUpButtonCell *popUpButtonCell = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:pullsDown];
    [popUpButtonCell setMenu:menu];
    if (!pullsDown) [popUpButtonCell selectItem:nil];
    [popUpButtonCell performClickWithFrame:frame inView:[sender view]];*/
	
    
	
    //[NSMenu popUpContextMenu:menu withEvent:event forView:sender];
	
	/*NSFetchRequest *frq = [[NSFetchRequest alloc] init];
	[frq setEntity:[NSEntityDescription entityForName:@"GMapFile" inManagedObjectContext:self.managedObjectContext]];
	NSArray *existing = [self.managedObjectContext executeFetchRequest:frq error:nil];
	[frq release];
	
	NSEnumerator *mapFileEnum = [existing objectEnumerator];
	GMapFile *curMapFile;
	while (curMapFile = [mapFileEnum nextObject]) {
		if (![mapFileNames containsObject:[curMapFile path]])
		{
			[self.managedObjectContext deleteObject:curMapFile];
		}
		else
			[mapFileNames removeObject:[curMapFile path]];
	}*/
}


#pragma mark -


- (IBAction)startBot:(id)sender
{
	Bot *bot = [[botsController selectedObjects] lastObject];
	if (bot)
		[bot start];
}
- (IBAction)stopBot:(id)sender
{
	Bot *bot = [[botsController selectedObjects] lastObject];
	if (bot)
		[bot stop];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
					hasVisibleWindows:(BOOL)flag
{
    if (![theApplication keyWindow]) {
		// show main window
		[[self window] orderFront:self];
	}
    return YES;
}

- (BOOL)windowShouldClose:(id)theWindow
{
	if (theWindow == [self window]) {
		// hide if main window
		[theWindow orderOut:self];
		return NO;
	}
	return YES;
}

-(id) init {
    if (self = [super init]) {
		localBotConfigController = [ConfigureLocalBotWindowController new];
		adminGameConfigController = [ConfigureAdminGameWindowController new];
		
		localBotView = [[ShowLocalBotViewController alloc] init];
		adminGameView = [ShowAdminGameViewController new];
		
		importWindowController = [[FileImportWindowController alloc] init];
		prefPaneMaps = [[PreferenceMapsController alloc] initWithObjectContext:self.managedObjectContext];
		prefPaneGeneral = [[PreferenceGeneralController alloc] init];
		botViewController = nil;
		
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *baseDir = [self applicationSupportDirectory];
		[fm createDirectoryAtPath:[baseDir stringByAppendingPathComponent:@"Map Configs"]
	  withIntermediateDirectories:YES 
					   attributes:nil
							error:nil];
		[fm createDirectoryAtPath:[baseDir stringByAppendingPathComponent:@"Warcraft III Files"]
	  withIntermediateDirectories:YES 
					   attributes:nil
							error:nil];
		[fm createDirectoryAtPath:[baseDir stringByAppendingPathComponent:@"Warcraft III Maps"]
	  withIntermediateDirectories:YES 
					   attributes:nil
							error:nil];
		
		fileWatcher = [[UKKQueue alloc] init];
	}
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	/*BOOL startHidden = [[[userDefaultsController values] valueForKey:@"startHidden"] boolValue];
	if (!startHidden)
		[mainWindow orderFront: mainWindow];*/
	NSNumber *startHidden = [[NSUserDefaults standardUserDefaults] valueForKey:@"startHidden"] ;
	if (!startHidden || ![startHidden boolValue])
		[[self window] orderFront: [self window]];
	[importWindowController showSheet:[self window]];
	
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[[TCMPortMapper sharedInstance] stopBlocking];
}

- (void)awakeFromNib {
	if (self.managedObjectContext)
	{
		[fileWatcher addPathToQueue:[self mapDir]];
		NSWorkspace* workspace = [NSWorkspace sharedWorkspace];
		NSNotificationCenter* notificationCenter = [workspace notificationCenter];
		[notificationCenter addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherRenameNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherWriteNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherDeleteNotification object:nil];
		[self refreshMaps];
	}
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:
															prefPaneGeneral,
															prefPaneMaps,
															nil]];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSManagedObject *obj = [[botsController selectedObjects] lastObject];
	if (obj == nil) {
		localBotView.selectedBot = nil;
		self.botViewController = nil;
	}
	
	// remove all subviews from the content view (there should only be one though)
	NSView *curView;
	NSArray *views = [[contentView subviews] copy];
	NSEnumerator *e = [views objectEnumerator];
	while (curView = [e nextObject]) {
		[curView removeFromSuperview];
	}
	[views release];
	
	if ([[[obj entity] name] isEqualToString:@"BotLocal"]) {
		localBotView.selectedBot = (BotLocal*)obj;
		NSRect contentFrame = [contentView frame];
		contentFrame.origin.x = 0;
		contentFrame.origin.y = 0;

		[contentView addSubview:[localBotView view]];
		[[localBotView view] setFrame:contentFrame];
		self.botViewController = localBotView;
		[modeChanger setEnabled:YES forSegment:1];
		
	} else if ([[[obj entity] name] isEqualToString:@"BotAdminGame"]) {
		adminGameView.selectedBot = (BotAdminGame*)obj;
		NSRect contentFrame = [contentView frame];
		contentFrame.origin.x = 0;
		contentFrame.origin.y = 0;
		
		[contentView addSubview:[adminGameView view]];
		[[adminGameView view] setFrame:contentFrame];
		self.botViewController = adminGameView;
		[modeChanger setEnabled:NO forSegment:1];
	}
}

- (IBAction)openConfigWindow:sender {
	NSManagedObject *obj = [[botsController selectedObjects] lastObject];
	if (obj == nil)
		return;
	if ([[[obj entity] name] isEqualToString:@"BotLocal"]) {
		if (![localBotConfigController isWindowLoaded])
			[localBotConfigController loadWindow];
		localBotConfigController.selectedBot = (BotLocal*)obj;
		[NSApp beginSheet: [localBotConfigController window]
		   modalForWindow: [self window]
			modalDelegate: nil
		   didEndSelector: nil
			  contextInfo: nil];
	} else if ([[[obj entity] name] isEqualToString:@"BotAdminGame"]) {
		if (![adminGameConfigController isWindowLoaded])
			[adminGameConfigController loadWindow];
		adminGameConfigController.selectedBot = (BotAdminGame*)obj;
		[NSApp beginSheet: [adminGameConfigController window]
		   modalForWindow: [self window]
			modalDelegate: nil
		   didEndSelector: nil
			  contextInfo: nil];
	}
}

- (IBAction)addLocalBot:(id)sender {
	//[[self undoManager] beginUndoGrouping];
	[NSEntityDescription insertNewObjectForEntityForName:@"BotLocal" inManagedObjectContext:[self managedObjectContext]];
	//[[self undoManager] endUndoGrouping];
	[[[self managedObjectContext] undoManager] setActionName:@"Added config"];
}

- (IBAction)addRemoteBot:(id)sender
{
	//[[self undoManager] beginUndoGrouping];
	[NSEntityDescription insertNewObjectForEntityForName:@"BotAdminGame" inManagedObjectContext:[self managedObjectContext]];
	//[[self undoManager] endUndoGrouping];
	[[[self managedObjectContext] undoManager] setActionName:@"Added config"];
}

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "Genie" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Genie"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
	// do a lightweight migration
	// (see http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmLightweight.html#//apple_ref/doc/uid/TP40008426-SW1 )
    //TODO: re-enable this and switch to 10.6 base sdk?
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, nil];
							 //[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"GenieDatabase"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:options 
                                                error:&error]){
		NSLog(@"Migration error: %@", [error description]);
		NSLog(@"Migration userInfo: %@", [[error userInfo] description]);
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
		[[NSApplication sharedApplication] terminate:nil];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
/*- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}*/


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

	// check for running instances
	NSArray *bots = [botsController arrangedObjects];
	NSEnumerator *e = [bots objectEnumerator];
	Bot *b;
	BOOL running = NO;
	while (b = [e nextObject]) {
		if ([b.running boolValue] && [[[b entity] name] isEqualToString:@"BotLocal"]) {
			running = YES;
			break;
		}
	}
	
	if (running && NSRunAlertPanel(@"Application Exit", @"One or more bots are still running, are you sure you want to quit?", @"Cancel", @"Quit", nil) != NSAlertAlternateReturn)
		return NSTerminateCancel;
	
	
    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
	[localBotView release];
	[localBotConfigController release];
	
    [super dealloc];
}


@end
