/*
 *  ghost-genie.h
 *  Genie
 *
 *  Created by Lucas on 28.03.10.
 *  Copyright 2010 Lucas Romero. All rights reserved.
 *
 */

#ifndef GHOSTGENIE_H
#define GHOSTGENIE_H

#include "ghost.h"
class CBNET;
class CBNETGenie;

//typedef void (*BotOutputCallback)( void* callbackObject, const string &message );
typedef void (*ProgressNotificationCallback)( void* callbackObject, int percent );

typedef enum GameEventType {
	GameEventTypeCreated,
	GameEventTypeDeleted
} GameEventType;
typedef struct GameEventData {
	GameEventType event;
	CBaseGame *game;
} GameEventData;
typedef void (*GameEventCallback)( void* callbackObject, const GameEventData &data );

typedef enum BNETEventType {
	BNETEventTypeWhisper,
	BNETEventTypeChat,
	BNETEventTypeEmote,
	BNETEventTypeConnecting,
	BNETEventTypeConnected,
	BNETEventTypeDisconnected,
	BNETEventTypeLoggedIn,
	BNETEventTypeGameRefreshed,
	BNETEventTypeGameRefreshFailed,
	BNETEventTypeConnectTimeout,
	BNETEventTypeChannelJoined,
	BNETEventTypeChatLeft,
	BNETEventTypeUserJoinedChannel,
	BNETEventTypeUserLeftChannel,
	BNETEventTypeIncomingFriend,
	BNETEVentTypeIncomingClanMember
} BNETEventType;

typedef struct BNETEventData {
	BNETEventType event;
	CBNET *bnet;
	string user;
	string message;
} BNETEventData;
typedef void (*BNETEventCallback)( void* callbackObject, const BNETEventData &data );


typedef struct BNETHashRequestData {
	string formula;
	string verString;
	CBNETGenie* bnet;
} EventBNETHashRequestData;
typedef void (*BNETHashRequestCallback)( void* callbackObject, const EventBNETHashRequestData &data );

class CGHostGenie : public CGHost
{
protected:
	BNETHashRequestCallback hashCallback;
	BNETEventCallback bnetCallback;
	GameEventCallback gameCallback;
	ProgressNotificationCallback ip2countryCallback;
	void *callbackObject;
	
	void OnGameEvent( GameEventType type, CBaseGame *game);
	void OnBNETMessage( BNETEventType type, CBNET *bnet, const string &user, const string &msg); 
	void OnBNETEvent( BNETEventType type, CBNET *bnet );
	void OnBNETEvent( BNETEventData &data);
	void OnBotMessage( const string &msg );
public:
	CGHostGenie( MessageLogger *logger, CConfig *CFG );
	
	virtual void EventBNETHashRequest( const EventBNETHashRequestData &data );
	
	virtual void EventBNETIncomingFriend( CBNET *bnet, string user, string status );
	virtual void EventBNETIncomingClanMember( CBNET *bnet, string user, string status );
	
	virtual void LoadIPToCountryData( string file );
	
	virtual void EventBNETConnecting( CBNET *bnet );
	virtual void EventBNETConnected( CBNET *bnet );
	virtual void EventBNETChannelJoined( CBNET *bnet, string user, string channel );
	virtual void EventBNETChatLeft( CBNET *bnet );
	virtual void EventBNETUserJoinedChannel( CBNET *bnet, string user, string channel );
	virtual void EventBNETUserLeftChannel( CBNET *bnet, string user, string channel );
	virtual void EventBNETDisconnected( CBNET *bnet );
	virtual void EventBNETLoggedIn( CBNET *bnet );
	virtual void EventBNETGameRefreshed( CBNET *bnet );
	virtual void EventBNETGameRefreshFailed( CBNET *bnet );
	virtual void EventBNETConnectTimedOut( CBNET *bnet );
	virtual void EventBNETWhisper( CBNET *bnet, string user, string message );
	virtual void EventBNETChat( CBNET *bnet, string user, string message );
	virtual void EventBNETEmote( CBNET *bnet, string user, string message );
	virtual void CreateGame( CMap *map, unsigned char gameState, bool saveGame, string gameName, string ownerName, string creatorName, string creatorServer, bool whisper );
	virtual void EventGameDeleted( CBaseGame *game );

	virtual void LoadIPToCountryData( );
	
	void RegisterCallbackObject( void *object)
	{
		callbackObject = object;
	}
	void RegisterHashCallback( BNETHashRequestCallback callback )
	{
		hashCallback = callback;
	}
	void RegisterBNETCallback( BNETEventCallback callback )
	{
		bnetCallback = callback;
	}
	void RegisterGameCallback( GameEventCallback callback )
	{
		gameCallback = callback;
	}
	void RegisterIP2CountryCallback( ProgressNotificationCallback callback )
	{
		ip2countryCallback = callback;
	}
};

#endif