//
//  GHostConfigFile.h
//  Genie
//
//  Created by Lucas on 03.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GHostConfigFile : NSObject
{
	NSString *name;
	NSString *path;
	NSString *content;
	BOOL isChanged;
	BOOL isLoaded;
}
@property(copy) NSString *path;
@property(copy) NSString *name;
@property(copy) NSString *content;
@property BOOL isChanged;
@property BOOL isLoaded;
- (id)initWithFile:(NSString*)fullpath;
- (void)loadContent;
- (void)saveContent;
- (void)revertContent;
@end
