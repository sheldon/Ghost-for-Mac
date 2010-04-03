//
//  ChatMessage.h
//  Genie
//
//  Created by Lucas on 11.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Message.h"

@class Channel;
@class User;

@interface ChatMessage :  Message  
{
}

@property (nonatomic, readonly, retain) NSImage *icon;

@property (nonatomic, retain) Channel * channel;
@property (nonatomic, retain) User * sender;

@end



