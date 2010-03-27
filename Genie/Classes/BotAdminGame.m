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
@dynamic commandTrigger;
@dynamic port;
@dynamic user;

- (void)initStream
{
	status = LANGameStatusNone;
	//NSHost *host = [NSHost hostWithName:@"amenophis.network.conceptt.com"];
	NSHost *host = [NSHost hostWithName:self.host];
	// iStream and oStream are instance variables
	[NSStream getStreamsToHost:host port:[self.port intValue] inputStream:&iStream outputStream:&oStream];
	[iStream retain];
	[oStream retain];
	[iStream setDelegate:self];
	[oStream setDelegate:self];
	[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[iStream open];
	[oStream open];
}

- (void)awakeFromFetch
{
	self.running = [NSNumber numberWithBool:NO];
	socket = nil;
	iStream = nil;
	oStream = nil;
	status = LANGameStatusNone;
	recvData = nil;

	[super awakeFromFetch];
}

- (void)awakeFromInsert
{
	self.name = @"AdminGame";
}

- (void)start
{
	self.running = [NSNumber numberWithBool:YES];
	/*if (!socket) {
		socket = [[AsyncSocket alloc] initWithDelegate:self];
		// Advanced options - enable the socket to contine operations even during modal dialogs, and menu browsing
		[socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
		[socket connectToHost:self.host onPort:[self.port intValue] withTimeout:10000 error:nil];
	}*/
	[self initStream];
}
- (void)stop
{
	if (iStream)
		[iStream close];
	if (oStream)
		[oStream close];
	self.running = [NSNumber numberWithBool:NO];
}

- (void)startStop
{
	BOOL _running = [self.running boolValue];
	if (_running)
		[self stop];
	else
		[self start];
}

- (void)messageReceived:(NSString*)message
{
	ConsoleMessage *msg = [NSEntityDescription insertNewObjectForEntityForName:@"ConsoleMessage" inManagedObjectContext:[self managedObjectContext]];
	msg.date = [NSDate date];
	msg.text = message;
	msg.bot = self;
	[self addMessagesObject:msg];
}

- (void)sendCommand:(NSString*)cmd
{
	
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;
{
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			NSLog(@"Socket connected");
			self.running = [NSNumber numberWithBool:YES];
			break;
		}
		case NSStreamEventHasBytesAvailable:
			if(!recvData) {
                recvData = [[NSMutableData data] retain];
            }
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)aStream read:buf maxLength:1024];
            if(len) {
                [recvData appendBytes:(const void *)buf length:len];

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
								
								//NSUInteger strLen = u16 - offset;
								NSRange strRange;
								strRange.location = offset;
								strRange.length = packet_size - offset;
								NSData *stringData = [recvData subdataWithRange:strRange];
								NSString *msg = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
								NSLog(@"Message received: %@", msg);
								[self messageReceived:msg];
								break;
							}
							case W3GS_PING_FROM_HOST:
							{
								//NSLog(@"Received Ping!");
								[oStream write:[recvData bytes] maxLength:packet_size];
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
								
								status = LANGameStatusJoined;
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
            } else {
                NSLog(@"no buffer!");
            }
			break;
		case NSStreamEventHasSpaceAvailable:
		{
			switch (status) {
				case LANGameStatusNone:
				{
					[self messageReceived:@"Joining admingame"];
					NSMutableData *sendData = [NSMutableData data];
					NSOutputStream *stream = (NSOutputStream*)aStream;
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
					[stream write:[sendData bytes] maxLength:[sendData length]];
					status = LANGameStatusJoinRequested;
					break;
				}
				case LANGameStatusJoined:
				{
					NSLog(@"Trying to log in");
					[self messageReceived:@"Trying to authenticate"];
					NSMutableData *sendData = [NSMutableData data];
					NSOutputStream *stream = (NSOutputStream*)aStream;
					
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
					
					NSString *text = [NSString stringWithFormat:@"%@password %@", self.commandTrigger, self.password];
					
					NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
					[sendData appendData:textData];
					
					[sendData setW3GSPacketLength];
					
					[stream write:[sendData bytes] maxLength:[sendData length]];
					status = LANGameStatusLoggingIn;
					break;
				}
			}
			break;
		}
		case NSStreamEventErrorOccurred:
			NSLog(@"Socket error");
			[self messageReceived:[@"Socket Error: " stringByAppendingString:[[aStream streamError] description]]];
			self.running = [NSNumber numberWithBool:NO];
			[oStream autorelease];
			oStream = nil;
			[iStream autorelease];
			iStream = nil;
			break;
		case NSStreamEventEndEncountered:
			NSLog(@"EOF");
			[self messageReceived:@"Connection closed"];
			self.running = [NSNumber numberWithBool:NO];
			[oStream autorelease];
			oStream = nil;
			[iStream autorelease];
			iStream = nil;
			
			break;
	}
}

@end
