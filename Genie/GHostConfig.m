/*
 This file is part of Genie.
 Copyright 2009 Lucas Romero

 Genie is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Genie is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Genie.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "GHostConfig.h"


@implementation GHostConfig
@synthesize content;
@synthesize name;
/*- (id)init {
	if ([super init]) {
		settings = [NSDictionary dictionaryWithObjectsAndKeys: @"6969", @"rcon_port", nil];
	}
	return self;
}*/
- (void)loadFile:(NSString*)path
{
	NSError *err;
	NSLog(@"Trying to load config file %@", path);
	//NSStringEncoding *enc = [NSStringEncoding
	fullPath = path;
	self.name = [path lastPathComponent];
	self.content = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&err];
}

- (void)saveFile
{
	[content writeToFile:fullPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
}

- (void)revertFile
{
	self.content = [NSString stringWithContentsOfFile:fullPath encoding:NSASCIIStringEncoding error:nil];
}

- (id)initWithFile:(NSString*)path
{
	if ([super init]) {
		[self loadFile:path];
	}
	return self;
}
@end
