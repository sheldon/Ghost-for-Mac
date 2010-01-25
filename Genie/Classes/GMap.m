// 
//  GMap.m
//  Genie
//
//  Created by Lucas on 21.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GMap.h"

#import "BotLocal.h"
#import "GMapFile.h"

@implementation GMap 

@dynamic hcl;
@dynamic loadIngame;
@dynamic title;
@dynamic clientPath;
@dynamic statsModule;
@dynamic mapfile;
@dynamic bots;
@dynamic settings;
- (NSArray*)clientPathSuggestions
{
	return [NSArray arrayWithObjects:
			@"Maps\\Download\\",
			@"Maps\\FrozenThrone\\Scenario\\",
			nil];
}
@end
