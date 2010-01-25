/*	Genie_AppDelegate.h
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

#import <Cocoa/Cocoa.h>

@class ConfigureLocalBotWindowController;
@class ShowLocalBotViewController;
@class FileImportWindowController;
@class PreferenceMapsController;
@class PreferenceGeneralController;
@class UKKQueue;

@interface Genie_AppDelegate : NSObject 
{
    NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	//IBOutlet NSArrayController *messagesController;
	IBOutlet NSArrayController *botsController;
	IBOutlet NSView *contentView;
	
	ConfigureLocalBotWindowController *localBotConfigController;
	ShowLocalBotViewController *localBotView;
	
	FileImportWindowController *importWindowController;
	
	PreferenceMapsController *prefPaneMaps;
	PreferenceGeneralController *prefPaneGeneral;
	
	UKKQueue *fileWatcher;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction)openConfigWindow:sender;

- (IBAction)addRemoteBot:(id)sender;
- (IBAction)addLocalBot:(id)sender;

- (IBAction)startBot:(id)sender;
- (IBAction)stopBot:(id)sender;

- (IBAction)loadMapButtonClicked:(id)sender;

- (NSString *)applicationSupportDirectory;

@end
