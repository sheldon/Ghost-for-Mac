// 
//  GMapFile.m
//  Genie
//
//  Created by Lucas on 21.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GMapFile.h"

#import "GMap.h"

@implementation GMapFile 

@dynamic path;
@dynamic maps;

- (NSString*)name
{
	return [self.path lastPathComponent];
}

@end
