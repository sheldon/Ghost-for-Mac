//
//  MapController.m
//  Genie
//
//  Created by Lucas on 18.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapController.h"
#import "GHostMapConfig.h"
#import "ghost4mac/GHostController.h"

@implementation MapController
@synthesize mapconfigs;
- (NSString *)title
{
	return NSLocalizedString(@"Maps", @"Title of 'Maps' preference pane");
}

- (NSString *)identifier
{
	return @"MapsPrefPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"map.png"];
}

- (void)textDidBeginEditing:(NSNotification *)note {
	NSLog(@"lol");
}

- (void)awakeFromNib
{
	NSArray *configs  = [[NSFileManager defaultManager] directoryContentsAtPath: mapDir];
	NSLog(mapDir);
	for(NSString *cfg in configs)
	{
		NSLog(@"%@ - %@", cfg, [[cfg pathExtension] lowercaseString]);
		if ([[cfg pathExtension] caseInsensitiveCompare: @"cfg"] == NSOrderedSame)
			[mapconfigController addObject: [[GHostMapConfig alloc] initWithFile:[mapDir stringByAppendingPathComponent:cfg]]];
	}
}

- (id)init
{
	self = [self initWithNibName:@"PreferencesMaps" bundle:nil];
	mapconfigs = [NSMutableArray array];
	mapDir = [[[GHostController sharedController] ghostDir] stringByAppendingPathComponent:@"mapcfgs"];
	
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditing:) name:NSControlTextDidBeginEditingNotification object:nil];
	return self;
}
@end
