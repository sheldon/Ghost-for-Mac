//
//  ConfigController.m
//  Genie
//
//  Created by Lucas on 18.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConfigController.h"
#import "UIController.h";


@implementation ConfigController
@synthesize cfgfiles;
- (NSString *)title
{
	return NSLocalizedString(@"Configs", @"Title of 'Configs' preference pane");
}

- (NSString *)identifier
{
	return @"ConfigsPrefPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSAdvanced"];
}

- (void)willBeDisplayed
{
	if ([[textEdit textStorage] length] == 0)
		[self editConfig:configSelector];
}

- (IBAction)revertConfig:(id)sender {
    [config revertFile];
}

- (IBAction)saveConfig:(id)sender {
    [config saveFile];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)editConfig:(id)sender {
	[config loadFile:[[UIController getConfigDir] stringByAppendingPathComponent: [[sender selectedItem] title]]];
}

- (IBAction)newConfig:(id)sender {
	NSRunAlertPanel(@"Oops!", @"Features not available yet", @"OK", @"Too bad", @"It's not that hard!");
	/*[NSApp beginSheet: newConfigPanel
	 modalForWindow: mainWindow
	 modalDelegate: self
	 didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
	 contextInfo: nil];*/
}

- (IBAction)newConfigAccept:(id)sender {
	[NSApp endSheet:newConfigPanel returnCode:NSOKButton];
}

- (IBAction)newConfigCancel:(id)sender {
	[NSApp endSheet:newConfigPanel returnCode:NSCancelButton];
}

- (id)init
{
	self = [self initWithNibName:@"PreferencesConfig" bundle:nil];
	NSArray *configs  = [[NSFileManager defaultManager] directoryContentsAtPath: [UIController getConfigDir]];
	NSMutableArray *tmpcfgfiles = [NSMutableArray array];
	
	for(NSString *cfg in configs)
	{
		//NSLog(@"%@ - %@", cfg, [[cfg pathExtension] lowercaseString]);
		if ([[cfg pathExtension] caseInsensitiveCompare: @"cfg"] == NSOrderedSame)
			[tmpcfgfiles addObject: cfg];
	}
	self.cfgfiles = [NSArray arrayWithArray:tmpcfgfiles];
	return self;
}
@end
