//
//  GHostConfigFile.m
//  Genie
//
//  Created by Lucas on 03.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GHostConfigFile.h"


@implementation GHostConfigFile
@synthesize name;
@synthesize path;
@synthesize isLoaded;
@synthesize isChanged;
- (id)init
{
	if ([super init]) {
		content = nil;
	}
	return self;
}

- (id)initWithFile:(NSString*)fullpath{
	if ([self init]) {
		self.path = fullpath;
		self.name = [fullpath lastPathComponent];
		self.content = nil;
		self.isLoaded = NO;
		self.isChanged = NO;
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)coder
{
	//[super encodeWithCoder:coder];
    [coder encodeObject: path];
    //[coder encodeObject: theNSDictionaryInstanceVariable];
    //[coder encodeValueOfObjCType:@encode(BOOL) at:&theBooleanInstanceVariable];
    //[coder encodeValueOfObjCType:@encode(float) at:&theFloatInstanceVariable];
}

-(id)initWithCoder:(NSCoder*)coder
{
   // if (self=[super initWithCoder:coder]) {
		return [self initWithFile:[coder decodeObject]];
	//}
}


- (NSString*)content
{
	return content;
}

- (void)setContent:(NSString*)value
{
	if (value != content)
	{
		if (content != nil)
			self.isChanged = YES;
		content = value;
	}
}

- (void)loadContent
{
	NSError *err;
	NSLog(@"Trying to load config file %@", path);
	
	if ((self.content = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&err]) == nil)
	{
		self.isLoaded = NO;
		NSLog(@"Error loading config: %@", err);
	}
	else
		self.isLoaded = YES;
	self.isChanged = NO;
}

- (void)saveContent
{
	NSLog(@"Trying to save config file %@", name);
	NSError *err;
	if (![content writeToFile:path atomically:YES encoding:NSASCIIStringEncoding error:&err])
		NSLog(@"Error writing config: %@", err);
	else
		self.isChanged = NO;
}

- (void)revertContent
{
	NSLog(@"Trying to revert config file %@", name);
	
	NSError *err;
	if ((self.content = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&err]) == nil)
		NSLog(@"Error loading config: %@", err);
	self.isChanged = NO;
}

@end
