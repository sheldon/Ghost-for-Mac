/*	BotLocal.m
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

#import "BotLocal.h"
#import "ConsoleMessage.h"
#import "ConfigEntry.h"
#import "User.h"
#import "ChatMessage.h"
#import "GMap.h"

#import "TCMPortMapper/TCMPortMapper.h"

#import "Server.h"
#import "ghost.h"
#import "bnet.h"
#import "config.h"
#import "map.h"

@implementation BotLocal

@dynamic settings;
@dynamic databaseName;
@dynamic motd;
@dynamic logFile;
@dynamic language;
@dynamic ipblacklist;
@dynamic startupMap;
@dynamic currentMap;

- (NSString *)applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Genie"];
}

- (void)setCurrentMap:(GMap *)map
{
	if(![self.running boolValue] || ![map mapfile])
		return;
	//TODO: save the current map
	NSArray *mapFileComponents = [[[map mapfile] path] pathComponents];
	NSArray *mapDirComponents = [[[self applicationSupportDirectory] stringByAppendingPathComponent:@"Warcraft III Maps"] pathComponents];
	int i=0;
	for(;i<[mapFileComponents count];i++) {
		if (![[mapFileComponents objectAtIndex:i] isEqualToString:[mapDirComponents objectAtIndex:i]])
			break;
	}
	NSRange theRange;
	
	theRange.location = i;
	theRange.length = [mapFileComponents count] - i;
	
	NSString *relMapPath = [NSString pathWithComponents:[mapFileComponents subarrayWithRange:theRange]];
							
	CGHost *ghost = (CGHost*)[[self.botInterface ghostInstance] pointerValue];
	CConfig *mapCfg = new CConfig( ghost );
	
	
	string map_path;
	if (![map clientPath]) {
		map_path = "Maps\\Download\\";
	}
	else {
		map_path = [[map clientPath] UTF8String];
	}

	
	mapCfg->Set( "map_path", map_path + [[relMapPath lastPathComponent] UTF8String] );
	
	mapCfg->Set( "map_localpath", [relMapPath UTF8String] );
	
	BOOL loadIngame = [map.loadIngame boolValue];
	mapCfg->Set( "map_loadingame", loadIngame ? "1" : "0" );
	
	if ([map hcl])
		mapCfg->Set( "map_defaulthcl", [[map hcl] UTF8String]);
	if ([map statsModule])
		mapCfg->Set( "map_type" , [[map statsModule] UTF8String]);
	
	//TODO: create NSManagedObject subclass for GMapValue
	NSEnumerator *e = [[map settings] objectEnumerator];
	while (NSManagedObject *entry = [e nextObject]) {
		if ([[entry name] length]) {
			if([[entry value] length])
				mapCfg->Set([[entry name] UTF8String], [[entry value] UTF8String]);
			else
				mapCfg->Set([[entry name] UTF8String], "");
		}
	}
	
	//TODO: make threadsafe
	ghost->m_Map->Load( mapCfg, [relMapPath UTF8String] );
	delete mapCfg;
}

#pragma mark -
#pragma mark undoing

- (void)disableUndo
{
	// disable undoing of message adding, as it is stupid
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] disableUndoRegistration];
}
- (void)enableUndo
{
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] enableUndoRegistration];
}

#pragma mark -
#pragma mark Helpers

- (NSString*)getTempFileName
{
	NSString *result = nil;
	NSString *tempFileTemplate =
    [NSTemporaryDirectory() stringByAppendingPathComponent:@"GenieProxyFile.XXXXXX"];
	const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
	
	
	char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
	strcpy(tempFileNameCString, tempFileTemplateCString);
	int fileDescriptor = mkstemp(tempFileNameCString);
	
	if (fileDescriptor == -1)
	{
		// handle file creation failure
	}
	else {
		result = [[NSFileManager defaultManager]
				  stringWithFileSystemRepresentation:tempFileNameCString
				  length:strlen(tempFileNameCString)];
	}
	
	
	free(tempFileNameCString);
	
	return result;
}

//TODO: don't force the extension to the file, especially not if the file already has an extension
- (NSString*)getDataFileFromName:(NSString*)file withExtension:(NSString*)ext
{
	if ([file isAbsolutePath]) {
		if ([[file pathExtension] isEqualToString:ext])
			return file;
		//else
		return [file stringByAppendingPathExtension:ext];
	}
	//else
	NSString *result = [self applicationSupportDirectory];
	result = [result stringByAppendingPathComponent:file];
	if (![[result pathExtension] isEqualToString:ext])
		result = [result stringByAppendingPathExtension:ext];
	return result;
}

- (void)portMapperDidStartWork:(NSNotification *)aNotification {
	NSLog(@"Portmapper started for port %d", [portMapping localPort]);
	[self performSelectorOnMainThread:@selector(consoleOutputCallback:)
						   withObject:@"[GENIE] Starting port mapper"
						waitUntilDone:NO];
}

- (void)portMapperDidFinishWork:(NSNotification *)aNotification {
    // since we only have one mapping this is fine
	NSLog(@"Portmapper finished");
    if ([portMapping mappingStatus]==TCMPortMappingStatusMapped) {
		[self performSelectorOnMainThread:@selector(consoleOutputCallback:)
							   withObject:@"[GENIE] Port mapping successful"
							waitUntilDone:NO];
    } else {
		[self performSelectorOnMainThread:@selector(consoleOutputCallback:)
							   withObject:@"[GENIE] Port mapping failed"
							waitUntilDone:NO];
    }
}

#pragma mark -
#pragma mark Start and Stop methods

- (void)start
{
	NSMutableDictionary *config = [NSMutableDictionary dictionaryWithCapacity:[[self settings] count]];
	NSEnumerator *e = [[self settings] objectEnumerator];
	while (ConfigEntry *entry = [e nextObject]) {
		if ([entry enabled] && [[entry name] length]) {
			[config setObject:[entry value] forKey:[entry name]];
		}
	}
	
	NSString *baseDir = [self applicationSupportDirectory];
	
	NSString *dbName = [NSString stringWithString:@"ghost.dbs"];
	if([[self databaseName] length]) {
		dbName = [self databaseName];
	}
	NSString *dbFullPath = [self getDataFileFromName:dbName withExtension:@"dbs"];
	[config setObject:dbFullPath forKey:@"db_sqlite3_file"];
	

	if([[self logFile] length]) {
		NSString *logfile = [self getDataFileFromName:[self logFile] withExtension:@"log"];
		[config setObject:logfile forKey:@"bot_log"];
	} else {
		[config setObject:@"" forKey:@"bot_log"];
	}
	
	NSString *motdFile = [self getTempFileName];
	[[self motd] writeToFile:motdFile atomically:NO encoding:NSUTF8StringEncoding error:nil];
	[config setObject:motdFile forKey:@"bot_motdfile"];
	
	

	NSBundle *thisBundle = [NSBundle mainBundle];
	NSString *langCfgPath;
	if (langCfgPath = [thisBundle pathForResource:[self language] ofType:@"cfg"])  {
		[config setObject:langCfgPath forKey:@"bot_language"];
	} else {
		[config setObject:@"language_file_not_found" forKey:@"bot_language"];
	}
	
	NSString *ip2country = [thisBundle pathForResource:@"ip-to-country" ofType:@"csv"];
	[config setObject:ip2country forKey:@"bot_ip2country"];
	
	
	if([[self ipblacklist] length]) {
		NSString *blacklist = [self getDataFileFromName:[self ipblacklist] withExtension:@"txt"];
		[config setObject:blacklist forKey:@"bot_ipblacklistfile"];
	} else {
		[config setObject:[thisBundle pathForResource:@"ipblacklist" ofType:@"txt"] forKey:@"bot_ipblacklistfile"];
	}
	

	[config setObject:[baseDir stringByAppendingPathComponent:@"Warcraft III Files"] forKey:@"bot_war3path"];
	[config setObject:[baseDir stringByAppendingPathComponent:@"Warcraft III Maps"] forKey:@"bot_mappath"];
	[config setObject:[baseDir stringByAppendingPathComponent:@"Map Configs"] forKey:@"bot_mapcfgpath"];
	
	
	[self.botInterface startBotWithConfig:config];
	/*[self disableUndo];
	self.running = [NSNumber numberWithBool:YES];
	[self enableUndo];*/
}

- (void)stop
{
	if ([self.botInterface running])
		[self.botInterface stop];
	/*[self disableUndo];
	self.running = [NSNumber numberWithBool:NO];
	[self enableUndo];*/
}

- (void)startStop
{
	if ([self.running boolValue])
		[self stop];
	else
		[self start];
}

- (NSNumber*)running
{
	return _running;
}

#pragma mark -
#pragma mark init and dealloc

- (void)awakeFromFetch
{
	_botInterface = nil;
	_running = [NSNumber numberWithBool:NO];
	TCMPortMapper *pm = [TCMPortMapper sharedInstance];
	/*[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(portMapperDidStartWork:)
	 name:TCMPortMapperDidStartWorkNotification
	 object:nil];
    [[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(portMapperDidFinishWork:)
	 name:TCMPortMapperDidFinishWorkNotification
	 object:nil];*/
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(portMapperDidStartWork:) 
												 name:TCMPortMapperDidStartWorkNotification object:pm];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(portMapperDidFinishWork:)
												 name:TCMPortMapperDidFinishWorkNotification object:pm];
	[super awakeFromFetch];
}

- (void)awakeFromInsert
{
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSString *cfgFile;
	if (cfgFile = [thisBundle pathForResource:@"ghost_default" ofType:@"cfg"])  {
		[self importConfig:cfgFile];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if ([keyPath isEqualToString:@"running"]) {
		//NSLog(@"Change: %@", [object description]);
		[self willChangeValueForKey:@"running"];
		_running = [[object running] copy];
		[self didChangeValueForKey:@"running"];
	}
}

- (GHostInterface*)botInterface
{
	if (!_botInterface) {
		_botInterface = [[GHostInterface alloc] init];
		[_botInterface setDelegate:self];
		[_botInterface addObserver:self forKeyPath:@"running" options:nil context:nil];
		//[_botInterface bind:@"running" toObject:self withKeyPath:@"running" options:nil];
	}
	return _botInterface;
}

- (void)dealloc
{
	[_botInterface release];
	[super dealloc];
}

#pragma mark -
#pragma mark GHost interaction

- (void)loadMap:(GMap*)map
{
	/*
	 CConfig MapCFG( m_GHost );
	 MapCFG.Set( "map_path", "Maps\\Download\\" + File );
	 MapCFG.Set( "map_localpath", File );
	 m_GHost->m_Map->Load( &MapCFG, File );
	 */
}

- (void)consoleOutputCallback:(NSString*)message
{
	[self disableUndo];
	
	ConsoleMessage *msg = [NSEntityDescription insertNewObjectForEntityForName:@"ConsoleMessage" inManagedObjectContext:[self managedObjectContext]];
	msg.date = [NSDate date];
	msg.text = message;
	msg.bot = self;
	[self addMessagesObject:msg];
	
	[self enableUndo];
}

- (void)ghostCreated:(CGHost*)ghost
{
	// get bnets
	int count = ghost->m_BNETs.size();
	for (int i=0; i<count; i++) {
		NSString *alias = [NSString stringWithUTF8String:ghost->m_BNETs[i]->GetServerAlias().c_str()];
		Server *srv = [NSEntityDescription insertNewObjectForEntityForName:@"Server" inManagedObjectContext:[self managedObjectContext]];
		srv.name = alias;
		srv.bot = self;
		void* bnet = ghost->m_BNETs[i];
		srv.bnetObject = [NSValue valueWithPointer:bnet];
		
		[self addServersObject:srv];
	}
	
	id enableUPnP = [[NSUserDefaults standardUserDefaults] objectForKey:@"enableUPnPPortMapping"];
	//enableUPnP = [NSNumber numberWithBool:YES];
	if (!enableUPnP || [enableUPnP boolValue]) {
		TCMPortMapper *pm = [TCMPortMapper sharedInstance];
		if (portMapping) {
			[pm removePortMapping:portMapping];
			[portMapping release];
		}
		portMapping = [[TCMPortMapping portMappingWithLocalPort:[[self.botInterface getHostPort] intValue]
										   desiredExternalPort:[[self.botInterface getHostPort] intValue]
											 transportProtocol:TCMPortMappingTransportProtocolTCP
													  userInfo:nil] retain];
		[pm addPortMapping:portMapping];
		[pm start];
	}
	// load startup map if any
	if (self.startupMap) {
		self.currentMap = self.startupMap;
	}
}

/*- (void)sendCommand:(NSDictionary *)cmd
{
	if ([self.botInterface running]) {
		[self.botInterface execCommand:cmd];
	}
}*/

- (Server*)getServerFromBNETPointer:(void*)bnet
{
	NSEnumerator *e = [[self servers] objectEnumerator];
	while (Server* server = [e nextObject]) {
		if([[server bnetObject] pointerValue] == bnet) {
			return server;
		}
	}
	return nil;
}

- (void)chatMessageReceived:(NSDictionary*)data
{
	void* bnet = [[data objectForKey:@"bnet"] pointerValue];
	NSString *user = [data objectForKey:@"user"];
	NSString *message = [data objectForKey:@"message"];
	Server *server = [self getServerFromBNETPointer:bnet];
	if (server) {
		User *usrObj = [server getUserForNick:user];
		ChatMessage *msgObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:[self managedObjectContext]];
		msgObj.date = [NSDate date];
		// TODO: set channel object
		msgObj.channel = nil;
		msgObj.text = message;
		msgObj.sender = usrObj;
		[usrObj addMessagesObject:msgObj];
	}
}
- (void)whisperReceived:(NSDictionary*)data
{
	void* bnet = [[data objectForKey:@"bnet"] pointerValue];
	NSString *user = [data objectForKey:@"user"];
	NSString *message = [data objectForKey:@"message"];
	Server *server = [self getServerFromBNETPointer:bnet];
	if (server) {
		User *usrObj = [server getUserForNick:user];
		ChatMessage *msgObj = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:[self managedObjectContext]];
		msgObj.date = [NSDate date];
		msgObj.channel = nil;
		msgObj.text = message;
		msgObj.sender = usrObj;
		[usrObj addMessagesObject:msgObj];
	}
}
- (void)emoteReceived:(NSDictionary*)data
{
	// TODO: handle emote
}

#pragma mark -
#pragma mark Config stuff

- (void)importConfig:(NSString *)path
{
	ifstream in;
	in.open( [path UTF8String] );
	
	if( in.fail( ) ) {
		//TODO: handle error
	}
	else
	{
		string Line;
		
		while( !in.eof( ) )
		{
			getline( in, Line );
			
			// ignore blank lines and comments
			
			if( Line.empty( ) || Line[0] == '#' )
				continue;
			
			// remove newlines and partial newlines to help fix issues with Windows formatted config files on Linux systems
			
			Line.erase( remove( Line.begin( ), Line.end( ), '\r' ), Line.end( ) );
			Line.erase( remove( Line.begin( ), Line.end( ), '\n' ), Line.end( ) );
			
			string :: size_type Split = Line.find( "=" );
			
			if( Split == string :: npos )
				continue;
			
			string :: size_type KeyStart = Line.find_first_not_of( " " );
			string :: size_type KeyEnd = Line.find( " ", KeyStart );
			string :: size_type ValueStart = Line.find_first_not_of( " ", Split + 1 );
			string :: size_type ValueEnd = Line.size( );
			
			if( ValueStart != string :: npos ) {
				NSString *key = [NSString stringWithUTF8String:Line.substr( KeyStart, KeyEnd - KeyStart ).c_str()];
				NSString *val = [NSString stringWithUTF8String:Line.substr( ValueStart, ValueEnd - ValueStart ).c_str()];
				//m_CFG[Line.substr( KeyStart, KeyEnd - KeyStart )] = Line.substr( ValueStart, ValueEnd - ValueStart );
				ConfigEntry *cfg = [NSEntityDescription insertNewObjectForEntityForName:@"ConfigEntry" inManagedObjectContext:[self managedObjectContext]];
				cfg.name = key;
				cfg.value = val;
				[self addSettingsObject:cfg];
			}
		}
		
		in.close( );
	}
}

@end
