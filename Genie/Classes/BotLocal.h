/*	BotLocal.h
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 01.01.10
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

#import <Cocoa/Cocoa.h>
#import "GHostInterface.h"
#import "Bot.h"
@class TCMPortMapping;
@class GMap;

@interface BotLocal : Bot <GBotProtocol,GHostDelegate> {
	GHostInterface* _botInterface;
	//NSNumber* _running;
	TCMPortMapping *portMapping;
	NSString *chatUserName;
}
@property (nonatomic, retain) NSString * chatUserName;


@property (nonatomic, retain) NSSet * settings;
@property (nonatomic, retain) NSString * databaseName;
@property (nonatomic, retain) NSString * motd;
@property (nonatomic, retain) NSString * logFile;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * ipblacklist;
@property (nonatomic, retain) GMap * startupMap;
@property (nonatomic, retain) GMap * currentMap;
@property (nonatomic, retain) NSNumber * useRemoteHasher;

@property (nonatomic, readonly) GHostInterface* botInterface;

- (void)importConfig:(NSString *)path;
- (NSString*)exportConfig;
- (void)loadMap:(GMap*)map;
@end

@interface BotLocal (CoreDataGeneratedAccessors)
- (void)addSettingsObject:(NSManagedObject *)value;
- (void)removeSettingsObject:(NSManagedObject *)value;
@end
