//
//  PanelStartupController.h
//  Genie
//
//  Created by Lucas on 27.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PanelStartupController : NSWindowController {
	NSMetadataQuery* searchQuery;
	NSTimer* searchTimer;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSTextField *statusText;
	IBOutlet NSButton *button;
	NSString* dataDir;
}
- (IBAction)stopSearchAction:(id)sender;
- (void)showSheet:(NSWindow*)parent;
- (void)copyFile:(NSString*)file toFolder:(NSString*)target;
- (void)stopSearching;
- (void)copyComplete;
- (void)updateProgress:(double)bytes;
@end

static void statusCallback (FSFileOperationRef fileOp,
							const FSRef *currentItem,
							FSFileOperationStage stage,
							OSStatus error,
							CFDictionaryRef statusDictionary,
							void *info );