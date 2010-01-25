/*	BotConfingViewControllerProtocol.m
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 27.09.09
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

#import "FileImportWindowController.h"

@implementation FileImportWindowController
- (NSString *)applicationSupportFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex: 0] : NSTemporaryDirectory();
	return [basePath stringByAppendingPathComponent: [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*)kCFBundleExecutableKey]];
}

- (id)init
{
	if (self = [self initWithWindowNibName:@"FileImportWindow"])
	{
		searchQuery = [[NSMetadataQuery alloc] init];
		[searchQuery setDelegate: self];
		dataDir = [[self applicationSupportFolder] retain];
		[[NSNotificationCenter defaultCenter] 
		 addObserver:self
		 selector:@selector(stopSearching)
		 name:NSMetadataQueryDidFinishGatheringNotification 
		 object:searchQuery];
	}
	return self;
}

- (void)dealloc
{
	[dataDir release];
	
	[[NSNotificationCenter defaultCenter] 
	 removeObserver:self
	 name:NSMetadataQueryDidFinishGatheringNotification 
	 object:searchQuery];
	[searchQuery release];
	[super dealloc];
}

- (void)close
{
	[NSApp endSheet:self.window];
    [self.window orderOut:self];
    [self.window close];
}

- (void)awakeFromNib
{
	
}

- (void)copyFile:(NSString*)file toFolder:(NSString*)target
{
	NSLog(@"Trying to copy '%@' to '%@'", file, target);
	// Use the NSFileManager to obtain the size of our source file in bytes.
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDictionary *sourceAttributes = [fileManager attributesOfItemAtPath:file error:nil];
	// pre 10.5 method
    //NSDictionary *sourceAttributes = [fileManager fileAttributesAtPath:file traverseLink:YES];
    NSNumber *sourceFileSize;
    
    if (sourceFileSize = [sourceAttributes objectForKey:NSFileSize] )
    {
        // Set the max value to our source file size
        [progressBar setMaxValue:(double)[sourceFileSize unsignedLongLongValue]];
    }
    else
    {
        // Couldn't get the file size so we need to bail.
        NSLog(@"Unable to obtain size of file being copied.");
        return;
    }
    [progressBar setDoubleValue:0.0];
	
    // Get the current run loop and schedule our callback
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    FSFileOperationRef fileOp = FSFileOperationCreate(kCFAllocatorDefault);
	
    OSStatus status = FSFileOperationScheduleWithRunLoop(fileOp, runLoop, kCFRunLoopDefaultMode);
	
    if( status )
    {
        NSLog(@"Failed to schedule operation with run loop: %@", status);
        return;
    }
    
    // Create a filesystem ref structure for the source and destination and
    // populate them with their respective paths
    FSRef source;
    FSRef destination;
    
    FSPathMakeRef( (const UInt8 *)[file fileSystemRepresentation], &source, NULL );
	
    Boolean isDir = true;
    FSPathMakeRef( (const UInt8 *)[target fileSystemRepresentation], &destination, &isDir );    
    
	FSFileOperationClientContext context;
	context.info = (void*)self;
	context.version = 0;
	context.retain = CFRetain;
	context.release = CFRelease;
	context.copyDescription = CFCopyDescription;
	
    // Start the async copy.
    status = FSCopyObjectAsync (fileOp,
                                &source,
                                &destination, // Full path to destination dir
                                NULL, // Use the same filename as source
                                kFSFileOperationDefaultOptions,
                                statusCallback,
                                1.0,
                                &context);
    
    CFRelease(fileOp);
    
    if( status )
    {
        NSLog(@"Failed to begin asynchronous object copy: %@", status);
    }
}

- (void)copyWar3Patch:(NSString*)file
{
	NSString *war3dir = [dataDir stringByAppendingPathComponent:@"Warcraft III Files"];
	[progressBar setIndeterminate:NO];
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm createDirectoryAtPath:war3dir withIntermediateDirectories:YES attributes:nil error:nil];
	[statusText setStringValue:@"Copying War3Patch.mpq"];
	[self copyFile:file toFolder:war3dir];
}

- (void)updateResults:(NSTimer*)timer
{
	int count = [[timer userInfo] resultCount];
	
    if (count > 0)
	{
		[self stopSearching];
		[statusText setStringValue:@"Found War3Patch.mpq"];
		NSMetadataItem *mdItem = [searchQuery resultAtIndex:0];
		[self copyWar3Patch:[mdItem valueForAttribute:(id)kMDItemPath]];
	}
	//[statusText setStringValue:[NSString stringWithFormat:@"Found %d %@ ...", count, count>1?@"files":@"file", nil]];
}

- (void)startPatchSearch
{
    // == is case insensitive
	NSPredicate *p = [NSPredicate predicateWithFormat:@"kMDItemFSName == 'War3Patch.mpq'"];
    [searchQuery setPredicate:p];
    [searchQuery setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryLocalComputerScope]];
	
    if ([searchQuery startQuery])
    {
        searchTimer = 
        [NSTimer scheduledTimerWithTimeInterval:0.5
										 target:self
									   selector:@selector(updateResults:)
									   userInfo:searchQuery
										repeats:YES];
        
        //NSRunLoop retains the timer
        [[NSRunLoop currentRunLoop] 
		 addTimer:searchTimer 
		 forMode:NSDefaultRunLoopMode];
		[progressBar startAnimation:self];
    }
    else
    {
		[statusText setStringValue:@"Error. Could not start query!"];
    }
}

- (void)stopSearching 
{
    //don't invalidate a timer more than once
	
    if (!([searchQuery isStopped]))
    {
		[searchTimer invalidate];
        [searchQuery stopQuery];
		[searchQuery disableUpdates];
		[progressBar stopAnimation:self];
		[statusText setStringValue:@"Search stopped"];
    }
}

- (void) dialogCopyFilesCallback:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if ( returnCode == NSOKButton )
	{
		[self copyWar3Patch:[sheet filename]];
	}
	else
		[self close];
}
	
- (void) alertManualSelectCallback:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSAlertFirstButtonReturn)
	{
		NSOpenPanel* openDlg = [NSOpenPanel openPanel];
		[openDlg setTitle:@"Please select War3Patch.mpq"];
		[openDlg setCanChooseFiles:YES];
		[openDlg setCanChooseDirectories:NO];
		
		[openDlg setAllowedFileTypes:[NSArray arrayWithObject:@"mpq"]];
		[openDlg setAllowsOtherFileTypes:NO];
		
		[openDlg setAllowsMultipleSelection:NO];
		
		while ([openDlg runModalForTypes:[NSArray arrayWithObject:@"mpq"]] == NSOKButton) {
			if ([[[openDlg filename] lastPathComponent] isEqualToString:@"War3Patch.mpq"])
			{
				[self copyWar3Patch:[openDlg filename]];
				break;
			}
			else
				NSRunAlertPanel (@"Invalid selection", @"Please only select War3Patch.mpq!", @"OK", nil, nil );
		}
		//[openDlg beginSheetForDirectory:nil file:nil modalForWindow:self.window modalDelegate:self didEndSelector:@selector(dialogCopyFilesCallback:returnCode:contextInfo:) contextInfo:nil];
	}
	else
	{
		[self close];
	}

}

- (IBAction)stopSearchAction:(id)sender
{
    [self stopSearching];
	//NSLog(@"NSButtont title: %@", [sender title]);
	if ([[sender title] isEqualToString:@"OK"])
		[self close];
	else
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"Yes"];
		[alert addButtonWithTitle:@"No"];
		[alert setMessageText:@"Required file missing!"];
		[alert setInformativeText:@"You aborted the search for the required file War3Patch.mpq.\nDo you want to manually select this file?"];
		//[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertManualSelectCallback:returnCode:contextInfo:) contextInfo:nil];
	}
}

- (void)showSheet:(NSWindow*)parent
{
	NSString *war3dir = [dataDir stringByAppendingPathComponent:@"Warcraft III Files"];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	/*check for necessary files*/
	NSError *error;
	[fm createDirectoryAtPath:war3dir withIntermediateDirectories:YES attributes:nil error:&error];
	
	if (![fm fileExistsAtPath:[war3dir stringByAppendingPathComponent:@"War3Patch.mpq"]])
	{
		[NSApp beginSheet: self.window
			modalForWindow: parent
			modalDelegate: self
			didEndSelector: nil
			contextInfo: nil];
		[self startPatchSearch];
	}
}
- (void)copyComplete
{
	[statusText setStringValue:@"Operation complete."];
	[button setTitle:@"OK"];
	[progressBar setDoubleValue:[progressBar maxValue]];
}
- (void)updateProgress:(double)bytes
{
	[progressBar setDoubleValue:bytes];
	[progressBar displayIfNeeded];
}
@end

static void statusCallback (FSFileOperationRef fileOp,
							const FSRef *currentItem,
							FSFileOperationStage stage,
							OSStatus error,
							CFDictionaryRef statusDictionary,
							void *info )
{
	FileImportWindowController *controller = (FileImportWindowController*)info;
    // If the status dictionary is valid, we can grab the current values
    // to display status changes, or in our case to update the progress
    // indicator.
	
	if (stage == kFSOperationStageComplete)
	{
		[controller copyComplete];
	}
	else if (statusDictionary)
    {
        CFNumberRef bytesCompleted;
        bytesCompleted = (CFNumberRef) CFDictionaryGetValue(statusDictionary, kFSOperationBytesCompleteKey);

		CGFloat floatBytesCompleted;
        CFNumberGetValue (bytesCompleted, kCFNumberMaxType, &floatBytesCompleted);
		
		[controller updateProgress:(double)floatBytesCompleted];
    }
}
