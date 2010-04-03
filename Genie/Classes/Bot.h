/*	Bot.h
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
#import "GBotProtocol.h"


@interface Bot :  NSManagedObject <GBotProtocol>
{
	NSNumber *running;
}
@property (nonatomic, retain) NSNumber * autoStart;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * hostPort;
@property (nonatomic, retain) NSNumber * adminCount;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * running;
@property (nonatomic, retain) NSSet* messages;
@property (nonatomic, retain) NSSet* games;
@property (nonatomic, retain) NSSet* servers;
- (void)sendCommand:(NSDictionary *)cmd;
@end


@interface Bot (CoreDataGeneratedAccessors)
- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

- (void)addGamesObject:(NSManagedObject *)value;
- (void)removeGamesObject:(NSManagedObject *)value;
- (void)addGames:(NSSet *)value;
- (void)removeGames:(NSSet *)value;

- (void)addServersObject:(NSManagedObject *)value;
- (void)removeServersObject:(NSManagedObject *)value;
- (void)addServers:(NSSet *)value;
- (void)removeServers:(NSSet *)value;

@end

