/*	BotConfingViewControllerProtocol.h
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

#import <Cocoa/Cocoa.h>

@interface FileImportWindowController : NSWindowController {
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