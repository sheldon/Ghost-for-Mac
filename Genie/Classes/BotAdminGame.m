// 
//  BotAdminGame.m
//  Genie
//
//  Created by Lucas on 08.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BotAdminGame.h"
#import "NSData+BinaryHelpers.h"
#import "NSMutableData+BinaryHelpers.h"
#import "ConsoleMessage.h"
#import "AsyncSocket.h"

@implementation BotAdminGame 

@dynamic password;
@dynamic host;
@dynamic port;
@dynamic user;

@dynamic autoReconnect;
@dynamic reconnectInterval;
@dynamic timeout;
@dynamic loggedIn;
@dynamic ignoreRefreshMessages;

- (void)messageReceived:(NSString*)message
{
	ConsoleMessage *msg = [NSEntityDescription insertNewObjectForEntityForName:@"ConsoleMessage" inManagedObjectContext:[self managedObjectContext]];
	msg.date = [NSDate date];
	msg.text = message;
	msg.bot = self;
	[self addMessagesObject:msg];
}

- (void)dealloc
{
	[cmdTrigger release];
	if (aSocket && [aSocket isConnected]) {
		[aSocket disconnect];
	}
	[super dealloc];
}

- (NSData*)getJoinPacket
{
	NSMutableData *sendData = [NSMutableData data];
	// header constant
	[sendData appendByte:W3GS_HEADER_CONSTANT];
	// type
	[sendData appendByte:W3GS_REQJOIN];
	// size
	[sendData appendUInt16:0];
	// tick counter
	[sendData appendUInt32:0];
	// tick count
	[sendData appendUInt32:0];
	// garbage byte
	[sendData appendByte:0];
	// game port
	[sendData appendUInt16:0];
	// game join/create counter
	[sendData appendUInt32:0];
	
	
	NSData *nickData = [self.user dataUsingEncoding:NSUTF8StringEncoding];
	[sendData appendData:nickData];
	
	// Always 0x0001? IPv4 type tag
	[sendData appendUInt16:1];
	// internal IP
	[sendData appendUInt32:0];
	[sendData appendUInt32:0];
	// forgot what this is
	[sendData appendUInt32:0];
	[sendData appendUInt32:0];
	
	[sendData setW3GSPacketLength];
	return sendData;
	//[stream write:[sendData bytes] maxLength:[sendData length]];
}

- (NSData*)getChatPacketForString:(NSString*)message
{
	NSMutableData *sendData = [NSMutableData data];
	
	[sendData appendByte:W3GS_HEADER_CONSTANT];
	[sendData appendByte:W3GS_CHAT_TO_HOST];
	// size
	[sendData appendUInt16:0];
	// recipient count
	[sendData appendByte:1];
	// recipient id #0
	[sendData appendByte:0];
	// sender pid
	[sendData appendByte:pid];
	// message type: chat
	[sendData appendByte:0x10];
	
	NSData *textData = [message dataUsingEncoding:NSUTF8StringEncoding];
	[sendData appendData:textData];
	
	[sendData setW3GSPacketLength];
	
	return sendData;
}

- (NSData*)getLoginPacketForCommandTrigger:(NSString*)trigger
{
	NSString *text = [NSString stringWithFormat:@"%@password %@", trigger, self.password];
	
	return [self getChatPacketForString:text];
}

- (void)awakeFromFetch
{
	self.running = [NSNumber numberWithBool:NO];
	aSocket = nil;
	recvData = nil;
	cmdTrigger = @"!";

	[super awakeFromFetch];
}

- (void)awakeFromInsert
{
	self.name = @"AdminGame";
}

- (void)start
{
	self.loggedIn = [NSNumber numberWithBool:NO];
	NSError *err = nil;
	[self messageReceived:[NSString stringWithFormat:@"Connecting to %@:%@", self.host, self.port]];
	if (!aSocket) {
		aSocket = [[AsyncSocket alloc] initWithDelegate:self];
	}
	if(![aSocket connectToHost:self.host onPort:[self.port intValue] error:&err])
	{
		[self messageReceived:[NSString stringWithFormat:@"Error: %@", err]];
	}
	else
		self.running = [NSNumber numberWithBool:YES];
}
static NSString *triggerInfo = @"Command trigger: ";
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if(!recvData) {
		recvData = [[NSMutableData data] retain];
	}
	//uint8_t buf[1024];
	//unsigned int len = 0;
	[recvData appendData:data];
	
	while ([recvData length] >= 4) { //header complete
		NSUInteger offset=0;
		uint8_t u8, packet_type;
		uint16_t u16, packet_size;
		
		// read packet header
		u8 = [recvData getByteOffsetIncrement:&offset];
		if (u8 != W3GS_HEADER_CONSTANT) {
			NSLog(@"WARNING: NO W3GS HEADER!");
		}
		// read packet type
		packet_type = [recvData getByteOffsetIncrement:&offset];
		
		// read packet size
		packet_size = [recvData getInt16OffsetIncrement:&offset];
		if ([recvData length] >= packet_size) {	//packet is complete
			switch (packet_type) {
				case W3GS_CHAT_FROM_HOST:
				{
					// read PID count
					u8 = [recvData getByteOffsetIncrement:&offset];
					// skip PIDs
					offset += u8;
					// sender
					u8 = [recvData getByteOffsetIncrement:&offset];
					// flag
					u8 = [recvData getByteOffsetIncrement:&offset];

					NSData *stringData = [recvData subdataWithRange:NSMakeRange(offset, packet_size - offset - 1)];
					NSString *msg = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
					NSLog(@"Message received: %@", msg);
					if (![self.loggedIn boolValue]) {
						
						if ([msg hasPrefix:triggerInfo]) {
							cmdTrigger = [[msg substringWithRange:NSMakeRange([triggerInfo length], 1)] retain];
							NSLog( @"Parsed command trigger '%@'", cmdTrigger );
							NSData *loginPacket = [self getLoginPacketForCommandTrigger:cmdTrigger];
							NSLog(@"Trying to log in");
							[self messageReceived:@"Trying to authenticate"];
							[sock writeData:loginPacket withTimeout:[self.timeout doubleValue]/1000 tag:0];
							// don't print trigger info
							break;
						}
						else if ([msg isEqualToString:@"Logged in."]) {
							self.loggedIn = [NSNumber numberWithBool:YES];
							[self messageReceived:@"Authentication successful"];
							// don't print message
							break;
						}
					}
					if ([self.ignoreRefreshMessages boolValue] && [msg hasPrefix:@"Battle.net game hosting succeeded on server"]) {
						break;
					}
					[self messageReceived:msg];
					break;
				}
				case W3GS_PING_FROM_HOST:
				{
					//NSLog(@"Received Ping!");
					[sock writeData:[recvData subdataWithRange:NSMakeRange(0, packet_size)] withTimeout:[self.timeout doubleValue]/1000 tag:0];
					break;
				}
				case W3GS_SLOTINFOJOIN:
				{
					NSLog(@"Joined Admin Game");
					[self messageReceived:@"Joined admingame"];
					// slotinfo count
					u16 = [recvData getInt16OffsetIncrement:&offset];
					// skip slotinfo
					offset += u16;
					// get PID
					pid = [recvData getByteOffsetIncrement:&offset];
					[sock writeData:[self getChatPacketForString:@"?trigger"] withTimeout:[self.timeout doubleValue]/1000 tag:0];
				}
					break;
					
				default:
					break;
			}
			
			// remove parsed data
			NSRange range;
			range.location = packet_size;
			range.length = [recvData length] - packet_size;
			[recvData setData:[recvData subdataWithRange:range]];
		} else {
			// packet is incomplete
			break;
		}
	}
	[sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	NSData *joinPacket = [self getJoinPacket];
	NSTimeInterval timeOut = [self.timeout doubleValue]/1000;
	[self messageReceived:@"Joining admingame"];
	[sock writeData:joinPacket withTimeout:timeOut tag:0];
	[sock readDataWithTimeout:timeOut tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
	if (!err && ![self.loggedIn boolValue]) {
		[self messageReceived:@"Disconnected by remote host. Check authentication."];
	}
	else {
		[self messageReceived:@"Disconnected by remote host."];
	}

}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	NSLog(@"onSocketDidDisconnect:%p", sock);
	self.running = [NSNumber numberWithBool:NO];
	self.loggedIn = [NSNumber numberWithBool:NO];
}

- (void)stop
{
	[aSocket disconnect];
}

- (void)startStop
{
	BOOL _running = [self.running boolValue];
	if (_running)
		[self stop];
	else
		[self start];
}

- (void)sendCommand:(NSString*)cmd
{
	if ([self.running boolValue]) {
		NSString *command = [cmdTrigger stringByAppendingString:cmd];
		[aSocket writeData:[self getChatPacketForString:command] withTimeout:[self.timeout doubleValue]/1000 tag:0];
	}
}

@end
