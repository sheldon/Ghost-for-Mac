//
//  Server.h
//  Genie
//
//  Created by Lucas on 12.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Bot;
@class Channel;
@class User;
@class ChatMessage;

@interface Server :  NSManagedObject  
{
	NSValue *bnetObject;
}

@property (nonatomic, retain) NSValue *bnetObject;

@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* users;
@property (nonatomic, retain) Channel * channel;
@property (nonatomic, retain) Bot * bot;
@property (nonatomic, retain) NSSet* messages;

- (User*)getUserForNick:(NSString*)nick;
- (ChatMessage*)channelMessage:(NSString*)message fromUser:(NSString*)user;
@end


@interface Server (CoreDataGeneratedAccessors)
- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)value;
- (void)removeUsers:(NSSet *)value;
- (void)addMessagesObject:(ChatMessage *)value;
- (void)removeMessagesObject:(ChatMessage *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

@end

