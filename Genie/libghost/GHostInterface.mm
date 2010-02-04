/*	GHostInterface.m
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

#import "GHostInterface.h"
#import "BotLocal.h"
#import "ConfigEntry.h"
#import "Server.h"

#import "ghost.h"
#import "config.h"
#import "bnet.h"
#import "bnetprotocol.h"

@implementation GHostInterface
NSString * const GOutputReceived = @"GOutputReceived";

@synthesize running;
@synthesize delegate;
@synthesize useRemoteHasher;

- (void)ghostCleanup
{
	
}

- (void)lineReceived:(NSString*)message {
	//NSLog(@"RECEIVED: '%@'", message);
	
	// switch from GHost thread to mainThread when leaving GHost context because
	// a) the message needs to be added to the managedObjectContext later which
	//    is not threadsafe
	// b) GHost's runLoop is timing sensitive and we want him to continue executing as soon as possible
	[delegate performSelectorOnMainThread:@selector(consoleOutputCallback:)
							   withObject:message
							waitUntilDone:NO];
}

//simple API that encodes reserved characters according to:
//RFC 3986
//http://tools.ietf.org/html/rfc3986
-(NSString *) urlencode: (NSString *) url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:
							@";" , @"/" , @"?" ,
							@":" , @"@" , @"&" ,
							@"=" , @"+" , @"$" ,
							@"," , @"[" , @"]" ,
							@"#" , @"!" , @"'" ,
							@"(" , @")" , @"*" ,
							@" " , @"^" ,
							nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:
							 @"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A",
							 @"+" , @"%5E",
							 nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    //NSString *out = [NSString stringWithString: temp];
	
    return [temp autorelease];
}

- (void)processHashData:(NSDictionary*)data
{
	CBNET *bnet = (CBNET*)[[data valueForKey:@"bnetObject"] pointerValue];
	NSString *exeInfo = [data valueForKey:@"EXEInfo"];
	NSString *exeVersion = [data valueForKey:@"EXEVersion"];
	NSString *exeVersionHash = [data valueForKey:@"EXEVersionHash"];
	
	if (exeInfo == nil || exeVersion == nil || exeVersionHash == nil) {
		[self lineReceived:@"[GENIE] Error getting hash from server"];
		bnet->ProcessFileHashes(string(), 0, 0);
	} else {
		[self lineReceived:@"[GENIE] Got hash from server"];
		NSLog(@"EXEVersion: '%@'\tEXEVersionHash: '%@'\tEXEInfo: '%@'", exeVersion, exeVersionHash, exeInfo);
		NSLog(@"EXEVersion: '%ld'\tEXEVersionHash: '%ld'\tEXEInfo: '%@'", [exeVersion longLongValue], [exeVersionHash longLongValue], exeInfo);
		bnet->ProcessFileHashes( string([exeInfo UTF8String]), [exeVersion longLongValue], [exeVersionHash longLongValue]);
	}
}

- (void)getHashForData:(NSDictionary*)data
{
	// set up autoreleasepool (needed because we are in a seperate thread)
	NSAutoreleasePool *autoreleasepool= [[NSAutoreleasePool alloc] init];
	
	[self lineReceived:@"[GENIE] Requesting hash from server"];
	
	NSString *formula = [data valueForKey:@"formula"];
	
	int mpqNum = -1;
	NSScanner *scanner = [NSScanner scannerWithString:[[data valueForKey:@"verString"] stringByDeletingPathExtension]];
	if ([scanner scanString:@"ver-IX86-" intoString:nil]) {
		[scanner scanInt:&mpqNum];
	}
	
	//formula = @"A=573383511 C=968605472 B=4154374016 4 A=A^S B=B-C C=C-A A=A^B";
	//mpqNum = 5;
	
	NSLog(@"Hash Formula: '%@'\tHash Version: '%d'", formula, mpqNum);
	NSLog(@"Encoded Formula: '%@'", [self urlencode:formula]);
	
	NSString *urlString = [NSString stringWithFormat:@"http://loginhashgen.appspot.com/hashserver?f=%@&m=%d", [self urlencode:formula], mpqNum];
	NSURL *url = [NSURL URLWithString:urlString];
	NSLog(@"Complete URL: '%@'", url);
	
	NSMutableDictionary *hashInfo = [NSMutableDictionary dictionaryWithCapacity:7];
	[hashInfo addEntriesFromDictionary:data];
	[hashInfo addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfURL:url]];
	
	//[self performSelector:@selector(processHashData:) onThread:ghostThread withObject:hashInfo waitUntilDone:NO];
	//TODO: thread safety!
	[self processHashData:hashInfo];
	
	[autoreleasepool release];
}

static void GHostOutputCallback(const std::string &message, void* receiver)
{
	GHostInterface *_self = (GHostInterface *)receiver;
	[_self lineReceived:[NSString stringWithUTF8String:message.c_str()]];
}

static void GHostBNETHashCallback(void* callbackObject, const EventBNETHashRequestData &data)
{
	GHostInterface *_self = (GHostInterface *)callbackObject;
	NSString *formula = [NSString stringWithUTF8String:data.formula.c_str()];
	NSString *verString = [NSString stringWithUTF8String:data.verString.c_str()];
	NSValue *bnetObject = [NSValue valueWithPointer:data.bnet];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  formula, @"formula",
						  verString, @"verString",
						  bnetObject, @"bnetObject",
						  nil];
	[_self performSelectorInBackground:@selector(getHashForData:) withObject:dict];
}

static void GHostBNETMessageCallback(void* callbackObject, CBNET *bnet, const string &user, const string &message, BNETMessageType type)
{
	GHostInterface *_self = (GHostInterface *)callbackObject;
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSValue valueWithPointer:bnet],@"bnet",
						  [NSString stringWithUTF8String:user.c_str()], @"user",
						  [NSString stringWithUTF8String:message.c_str()], @"message", nil];
	switch (type) {
		case BNETMessageTypeChat:
			[[_self delegate] performSelectorOnMainThread:@selector(chatMessageReceived:)
											   withObject:dict
											waitUntilDone:NO];
			break;
		case BNETMessageTypeWhisper:
			[[_self delegate] performSelectorOnMainThread:@selector(whisperReceived:)
											   withObject:dict
											waitUntilDone:NO];
			break;
		case BNETMessageTypeEmote:
			[[_self delegate] performSelectorOnMainThread:@selector(emoteReceived:)
											   withObject:dict
											waitUntilDone:NO];
			break;
	}
	
}

- (void)execCommand:(NSDictionary *)cmd
{
	// lock in order to change the cmdQueue
	[cmdLock lock];
	[cmdQueue addObject:cmd];
	[cmdLock unlock];
}

- (void)runLoop:(id)data {
	// set up autoreleasepool (needed because we are in a seperate thread)
	NSAutoreleasePool *autoreleasepool= [[NSAutoreleasePool alloc] init];
	
	// set priority to high
	[NSThread setThreadPriority:1.0];
	
	[self willChangeValueForKey:@"running"];
	running = [NSNumber numberWithBool:YES];
	[self didChangeValueForKey:@"running"];
	cancelled = NO;
	
	instance = new CGHost(cfg, &GHostOutputCallback, (void*)self);
	instance->RegisterBNETCallback(&GHostBNETMessageCallback, (void*)self);
	if ([useRemoteHasher boolValue])
		instance->RegisterBNETHashCallback(&GHostBNETHashCallback, (void*)self);
	
	if (delegate) {
		[delegate performSelectorOnMainThread:@selector(ghostCreated:) withObject:[NSValue valueWithPointer:instance] waitUntilDone:YES];
	}

	while (!cancelled) {
		// don't wait for locking in order to keep blocking of this thread to a minimum
		// it is not critical if we miss this once or twice anyway
		if ([cmdLock tryLock]) {
			// lock was aquired
			while ([cmdQueue count]) {
				// pop object, retain and autorelease because we will call removeObject in the next line
				NSDictionary *cmd = [[[cmdQueue objectAtIndex:0] retain] autorelease];
				[cmdQueue removeObject:cmd];
				
				Server *server = [cmd valueForKey:@"server"];
				CBNET *bnet = (CBNET*)[[server bnetObject] pointerValue];
				
				char trigger = bnet->GetCommandTrigger();
				string *command = new string([[cmd valueForKey:@"command"] UTF8String]);
				command->insert(0, 1, trigger);
				NSLog(@"Trying to send command '%s' to server '%s'", command->c_str(), bnet->GetServerAlias().c_str());
				
				CIncomingChatEvent *event = new CIncomingChatEvent(CBNETProtocol::EID_WHISPER,
																   0,
																   bnet->GetRootAdmin(),
																   *command);
				bnet->ProcessChatEvent( event );
				delete event;
				delete command;
			}
			[cmdLock unlock];
		}
		//self.running = YES;
		if (instance->Update(50000)){
			break;
		}
	}
	instance->m_ExitingNice = TRUE;
	instance->Update(1);
	if (delegate) {
		[delegate performSelectorOnMainThread:@selector(ghostTerminates:) withObject:[NSValue valueWithPointer:instance] waitUntilDone:YES];
	}

	delete cfg;
	cfg = nil;
	delete instance;
	instance = nil;
	[self willChangeValueForKey:@"running"];
	running = [NSNumber numberWithBool:NO];
	[self didChangeValueForKey:@"running"];
	
	[autoreleasepool release];
}

/*int count = instance->m_BNETs.size();
 for (int i=0; i<count; i++) {
 NSString *target = [cmd valueForKey:@"server"];
 NSString *server = [NSString
 stringWithUTF8String:instance->m_BNETs[i]->GetServerAlias().c_str()];
 // do we have no target or
 // was the command meant to be executed on this server?
 if (!target || ![target length] || [target isEqualToString:server]) {
 char trigger = instance->m_BNETs[i]->GetCommandTrigger();
 std::string command = string([[cmd valueForKey:@"command"] UTF8String]);
 command.insert(0, 1, trigger);
 
 CIncomingChatEvent *event = new CIncomingChatEvent(CBNETProtocol::EID_WHISPER,
 0,
 instance->m_BNETs[i]->GetRootAdmin(),
 command);
 instance->m_BNETs[i]->ProcessChatEvent( event );
 delete event;
 break;
 }
 }*/
- (NSValue*)ghostInstance
{
	return [NSValue valueWithPointer:instance];
}
- (NSNumber*)getHostPort {
	if (instance != nil) {
		return [NSNumber numberWithInt:instance->m_HostPort];
	}
	return [NSNumber numberWithInt:0];
}
- (void)startBotWithConfig:(NSDictionary *)config {
	if (![ghostThread isExecuting]) {
		//botObject = bot;
		// release old object
		[ghostThread autorelease];
		// init thread
		ghostThread = [[NSThread alloc] initWithTarget:self
											 selector:@selector(runLoop:)
											   object:nil];
		[ghostThread setName:@"GHostRunloop"];
		
		
		if (cfg != nil)
			delete cfg;
		cfg = new CConfig( NULL );
		
		NSEnumerator *e = [config keyEnumerator];
		NSString *key;
		while (key = [e nextObject]) {
			const char *a = [key UTF8String];
			const char *b = [[config objectForKey:key] UTF8String];
			string val = string( );
			if (b != NULL)
				val = string(b);
			cfg->Set(string(a), val);
		}
		
		[ghostThread start];  // Actually create and start the thread
	}
}
- (void)stop {
	cancelled = YES;
}
- (id)init {
	if (self = [super init]) {
		instance = nil;
		running = NO;
		useRemoteHasher = [NSNumber numberWithBool:YES];
		cmdQueue = [[NSMutableArray arrayWithCapacity:5] retain];
		cmdLock = [[NSLock alloc] init];
		delegate = nil;
	}
	return self;
}

- (void)dealloc {
	if (ghostThread)
		[ghostThread release];
	[cmdLock release];
	if (instance != nil)
		delete instance;
	if (cfg != nil)
		delete cfg;
	[super dealloc];
}

@end
