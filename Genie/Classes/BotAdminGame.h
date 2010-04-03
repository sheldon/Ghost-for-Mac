//
//  BotAdminGame.h
//  Genie
//
//  Created by Lucas on 08.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Bot.h"

@class AsyncSocket;

enum {
    LANGameStatusNone = 0,
    LANGameStatusJoinRequested = 1,
	LANGameStatusJoined = 2,
	LANGameStatusLoggingIn = 3,
	LANGameStatusLoggedIn = 4
};
typedef NSUInteger LANGameStatus;

#define W3GS_HEADER_CONSTANT		247
enum WC3Protocol {
	W3GS_PING_FROM_HOST		= 1,	// 0x01
	W3GS_SLOTINFOJOIN		= 4,	// 0x04
	W3GS_REJECTJOIN			= 5,	// 0x05
	W3GS_PLAYERINFO			= 6,	// 0x06
	W3GS_PLAYERLEAVE_OTHERS	= 7,	// 0x07
	W3GS_GAMELOADED_OTHERS	= 8,	// 0x08
	W3GS_SLOTINFO			= 9,	// 0x09
	W3GS_CHAT_FROM_HOST		= 15,	// 0x0F
	W3GS_HOST_KICK_PLAYER	= 28,	// 0x1C
	W3GS_REQJOIN			= 30,	// 0x1E
	W3GS_LEAVEGAME			= 33,	// 0x21
	W3GS_CHAT_TO_HOST		= 40,	// 0x28
	W3GS_DROPREQ			= 41,	// 0x29
	W3GS_SEARCHGAME			= 47,	// 0x2F (UDP/LAN)
	W3GS_GAMEINFO			= 48,	// 0x30 (UDP/LAN)
	W3GS_CREATEGAME			= 49,	// 0x31 (UDP/LAN)
	W3GS_REFRESHGAME		= 50,	// 0x32 (UDP/LAN)
	W3GS_DECREATEGAME		= 51,	// 0x33 (UDP/LAN)
	W3GS_CHAT_OTHERS		= 52,	// 0x34
	W3GS_PING_FROM_OTHERS	= 53,	// 0x35
	W3GS_PONG_TO_OTHERS		= 54,	// 0x36
	W3GS_PONG_TO_HOST		= 70,	// 0x46
};

@interface BotAdminGame :  Bot
{
	NSMutableData *recvData;
	uint8_t pid;
	AsyncSocket *aSocket;
	NSString *cmdTrigger;
}

- (void)sendCommand:(NSString*)cmd;

@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSNumber * autoReconnect;
@property (nonatomic, retain) NSNumber * reconnectInterval;
@property (nonatomic, retain) NSNumber * timeout;
@property (nonatomic, retain) NSNumber * loggedIn;
@property (nonatomic, retain) NSNumber * ignoreRefreshMessages;

@end



