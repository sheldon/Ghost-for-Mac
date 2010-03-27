/*	GHostInterface.h
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 03.01.10
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
#ifdef __cplusplus
//#import "ghost.h"
class CGHost;
class CConfig;
#endif

#ifdef __cplusplus
#define FAKE_CXX_TYPE(type) type
#else
#define FAKE_CXX_TYPE(type) void *
#endif

@class BotLocal;

@protocol GHostDelegate
/* all messages are invoked on the mainThread */
- (void)ghostCreated:(NSValue*)ghost;
- (void)ghostTerminates:(NSValue*)ghost;
- (void)consoleOutputCallback:(NSString*)message;
- (void)chatMessageReceived:(NSDictionary*)data;
- (void)whisperReceived:(NSDictionary*)data;
- (void)emoteReceived:(NSDictionary*)data;

@end


@interface GHostInterface : NSObject {
	FAKE_CXX_TYPE(CGHost *)instance;
	FAKE_CXX_TYPE(CConfig*)cfg;
	NSThread* ghostThread;
	BOOL cancelled;
	NSNumber* running;
	NSMutableArray *cmdQueue;
	NSLock *cmdLock;
	NSLock *mainLock;
	NSObject <GHostDelegate> *delegate;
	NSNumber *useRemoteHasher;
	//NSNumber *hostPort;
}
extern NSString * const GOutputReceived;
- (void)startBotWithConfig:(NSDictionary *)config;
- (void)stop;
- (NSNumber*)getHostPort;
- (NSValue*)ghostInstance;
- (void)execCommand:(NSDictionary *)cmd;
- (void)getLock;
- (void)releaseLock;
@property (nonatomic, retain) NSNumber* running;
@property (nonatomic, readonly) NSNumber* useRemoteHasher;
@property (assign) NSObject <GHostDelegate> *delegate;
@end
