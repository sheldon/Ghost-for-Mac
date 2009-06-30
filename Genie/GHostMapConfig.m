//
//  GHostMapConfig.m
//  Genie
//
//  Created by Lucas on 30.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GHostMapConfig.h"


@implementation GHostMapConfig
@synthesize name;
- (void)loadFile:(NSString*)path
{
	NSError *err;
	NSLog(@"Trying to load config file %@", path);
	//NSStringEncoding *enc = [NSStringEncoding
	fullPath = path;
	self.name = [path lastPathComponent];
	//if ((self.content = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&err]) == nil)
		//NSLog(@"Error loading config: %@", err);
}

- (id)initWithFile:(NSString*)path
{
	if ([super init]) {
		[self loadFile:path];
	}
	return self;
}

@end
