//
//  ChatMessage.m
//  Genie
//
//  Created by Lucas on 25.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChatMessage.h"


@implementation ChatMessage
@synthesize image;
@synthesize sender;
@synthesize text;
@synthesize realm;
@synthesize date;
@synthesize isCommand;
@synthesize isWhisper;
@synthesize isVirtualMessage;
- (id)init
{
	self.isWhisper = NO;
	self.isCommand = NO;
	self.isVirtualMessage = NO;
	return self;
}
- (id)initWithText:(NSString*)newText sender:(NSString*)newSender date:(NSDate*)newDate image:(NSImage*)newImage
{
	if (self = [self init]) {
		if (newImage == nil)
			newImage = [NSImage imageNamed:@"NSInfo"];
		self.text = newText;
		self.sender = newSender;
		self.date = newDate;
		self.image = newImage;
	}
	return self;
}
+ (id)chatMessageWithText:(NSString*)text sender:(NSString*)sender date:(NSDate*)date image:(NSImage*)image
{
	return [[[ChatMessage alloc] initWithText:text sender:sender date:date image:image] autorelease];
}
@end
