/*	User.h
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 06.01.10
 *
 *	Genie is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	Genie is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 * 	You should have received a copy of the GNU General Public License
 * 	along with Genie.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <CoreData/CoreData.h>

@class ChatMessage;
@class ClanInfo;
@class FriendInfo;

@interface User :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSManagedObject * server;
@property (nonatomic, retain) NSManagedObject * channel;
@property (nonatomic, retain) NSSet* messages;
@property (nonatomic, retain) ClanInfo * clanInfo;
@property (nonatomic, retain) FriendInfo * friendInfo;

@property (nonatomic, readonly, retain) NSImage *icon;

@end

@interface User (CoreDataGeneratedAccessors)
- (void)addMessagesObject:(ChatMessage *)value;
- (void)removeMessagesObject:(ChatMessage *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

@end



