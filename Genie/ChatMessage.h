//
//  ChatMessage.h
//  Genie
//
//  Created by Lucas on 25.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ChatMessage : NSObject {
	NSImage *image;
	NSString *sender;
	NSString *realm;
	NSDate *date;
	NSString *text;
	BOOL isCommand;
	BOOL isWhisper;
	BOOL isVirtualMessage;
}
@property(copy) NSImage* image;
@property(copy) NSString* sender;
@property(copy) NSString* text;
@property(copy) NSString* realm;
@property(copy) NSDate*	date;
@property BOOL isCommand;
@property BOOL isWhisper;
@property BOOL isVirtualMessage;

+ (id)chatMessageWithText:(NSString*)text sender:(NSString*)sender date:(NSDate*)date image:(NSImage*)image;
@end
