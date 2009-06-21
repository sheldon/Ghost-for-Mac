//
//  ConfigController.h
//  Genie
//
//  Created by Lucas on 18.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"
#import "GHostConfig.h"

@interface ConfigController : NSViewController <MBPreferencesModule> {
	NSArray *cfgfiles;
	IBOutlet id ghost;
	IBOutlet GHostConfig *config;
	IBOutlet NSPopUpButton *configSelector;
	IBOutlet NSPanel *newConfigPanel;
	IBOutlet NSTextField *newConfigName;
	IBOutlet NSTextView *textEdit;
}
@property(retain) NSArray *cfgfiles;
- (IBAction)editConfig:(id)sender;
- (IBAction)newConfig:(id)sender;
- (IBAction)revertConfig:(id)sender;
- (IBAction)saveConfig:(id)sender;
- (IBAction)newConfigAccept:(id)sender;
- (IBAction)newConfigCancel:(id)sender;
@end
