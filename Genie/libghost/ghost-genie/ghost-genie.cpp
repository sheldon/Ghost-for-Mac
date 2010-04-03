/*
 *  ghost-genie.cpp
 *  Genie
 *
 *  Created by Lucas on 28.03.10.
 *  Copyright 2010 Lucas Romero. All rights reserved.
 *
 */

#include "ghost-genie.h"
#include "bnet-genie.h"

#include "csvparser.h"
#include "util.h"
#include "ghostdb.h"

CGHostGenie :: CGHostGenie( MessageLogger *logger, CConfig *CFG ) : CGHost( logger, CFG ),
hashCallback( NULL ),
bnetCallback( NULL ),
gameCallback( NULL ),
ip2countryCallback( NULL)
{
	vector<CBNET*> newBNETs;
	for( vector<CBNET *> :: iterator i = m_BNETs.begin( ); i != m_BNETs.end( ); i++ )
	{
		CBNET *o = *i;
		CBNETGenie *bnet = new CBNETGenie( this, o, true );
		newBNETs.push_back( bnet );
	}
	// swap bnet lists
	m_BNETs.swap(newBNETs);
	// newBNETs now contains the old bnet instances that can be thrown away
	newBNETs.clear();
}

void CGHostGenie :: LoadIPToCountryData( )
{
	// just don't load it yet, we will call LoadIPToCountryData(string) later
	// blocking the call
	// CGHost :: LoadIPToCountryData( );
}

void CGHostGenie :: LoadIPToCountryData( string file )
{
	ifstream in;
	in.open( file.c_str( ) );
	
	if( in.fail( ) )
		LogWarning( "[GHOST] warning - unable to read file [" + file + "], iptocountry data not loaded" );
	else
	{
		LogInfo( "[GHOST] started loading [" + file + "]" );
		
		// the begin and commit statements are optimizations
		// we're about to insert ~4 MB of data into the database so if we allow the database to treat each insert as a transaction it will take a LONG time
		// todotodo: handle begin/commit failures a bit more gracefully
		
		if( !m_DBLocal->Begin( ) )
			LogWarning( "[GHOST] warning - failed to begin local database transaction, iptocountry data not loaded" );
		else
		{
			unsigned char Percent = 0;
			string Line;
			string IP1;
			string IP2;
			string Country;
			CSVParser parser;
			
			// get length of file for the progress meter
			
			in.seekg( 0, ios :: end );
			uint32_t FileLength = in.tellg( );
			in.seekg( 0, ios :: beg );
			
			while( !in.eof( ) )
			{
				getline( in, Line );
				
				if( Line.empty( ) )
					continue;
				
				parser << Line;
				parser >> IP1;
				parser >> IP2;
				parser >> Country;
				m_DBLocal->FromAdd( UTIL_ToUInt32( IP1 ), UTIL_ToUInt32( IP2 ), Country );
				
				// it's probably going to take awhile to load the iptocountry data (~10 seconds on my 3.2 GHz P4 when using SQLite3)
				// so let's print a progress meter just to keep the user from getting worried
				
				unsigned char NewPercent = (unsigned char)( (float)in.tellg( ) / FileLength * 100 );
				
				if( NewPercent != Percent )
				{
					if( NewPercent % 10 == 0 )
						LogInfo( "[GHOST] iptocountry data: " + UTIL_ToString( NewPercent ) + "% loaded" );
					Percent = NewPercent;
					if( ip2countryCallback )
						ip2countryCallback( callbackObject, NewPercent );
				}
			}
			
			if( !m_DBLocal->Commit( ) )
				LogWarning( "[GHOST] warning - failed to commit local database transaction, iptocountry data not loaded" );
			else
				LogInfo( "[GHOST] finished loading [ip-to-country.csv]" );
		}
		
		in.close( );
	}
}

void CGHostGenie :: OnBNETMessage( BNETEventType type, CBNET *bnet, const string &user, const string &msg)
{
	BNETEventData d;
	d.bnet = bnet;
	d.event = type;
	d.user = user;
	d.message = msg;
	OnBNETEvent( d );
}

void CGHostGenie :: OnBNETEvent( BNETEventType type, CBNET *bnet )
{
	BNETEventData d;
	d.bnet = bnet;
	d.event = type;
	OnBNETEvent( d );
}

void CGHostGenie :: OnBNETEvent( BNETEventData &data)
{
	if( bnetCallback != NULL )
		bnetCallback( callbackObject, data );
}

void CGHostGenie :: EventBNETHashRequest( const EventBNETHashRequestData &data )
{
	if( hashCallback != NULL )
		hashCallback( callbackObject, data );
}

void CGHostGenie :: EventBNETIncomingFriend( CBNET *bnet, string user, string status )
{
	OnBNETMessage( BNETEventTypeIncomingFriend, bnet, user, status );
}

void CGHostGenie :: EventBNETIncomingClanMember( CBNET *bnet, string user, string status )
{
	OnBNETMessage( BNETEVentTypeIncomingClanMember, bnet, user, status );
}

void CGHostGenie :: EventBNETConnecting( CBNET *bnet )
{
	CGHost :: EventBNETConnecting( bnet );
	OnBNETEvent( BNETEventTypeConnecting, bnet );
}

void CGHostGenie :: EventBNETConnected( CBNET *bnet )
{
	CGHost :: EventBNETConnected( bnet );
	OnBNETEvent( BNETEventTypeConnected, bnet );
}

void CGHostGenie :: EventBNETChannelJoined( CBNET *bnet, string user, string channel )
{
	OnBNETMessage( BNETEventTypeChannelJoined, bnet, user, channel );
}

void CGHostGenie :: EventBNETChatLeft( CBNET *bnet )
{
	OnBNETEvent( BNETEventTypeChatLeft, bnet );
}

void CGHostGenie :: EventBNETUserJoinedChannel( CBNET *bnet, string user, string channel )
{
	OnBNETMessage( BNETEventTypeUserJoinedChannel, bnet, user, channel );
}

void CGHostGenie :: EventBNETUserLeftChannel( CBNET *bnet, string user, string channel )
{
	OnBNETMessage( BNETEventTypeUserLeftChannel, bnet, user, channel );
}

void CGHostGenie :: EventBNETDisconnected( CBNET *bnet )
{
	CGHost :: EventBNETDisconnected( bnet );
	OnBNETEvent( BNETEventTypeDisconnected, bnet );
}

void CGHostGenie :: EventBNETLoggedIn( CBNET *bnet )
{
	CGHost :: EventBNETLoggedIn( bnet );
	OnBNETEvent( BNETEventTypeLoggedIn, bnet );
}

void CGHostGenie :: EventBNETGameRefreshed( CBNET *bnet )
{
	CGHost :: EventBNETGameRefreshed( bnet );
	OnBNETEvent( BNETEventTypeGameRefreshed, bnet );
}

void CGHostGenie :: EventBNETGameRefreshFailed( CBNET *bnet )
{
	CGHost :: EventBNETGameRefreshFailed( bnet );
	OnBNETEvent( BNETEventTypeGameRefreshFailed, bnet );
}

void CGHostGenie :: EventBNETConnectTimedOut( CBNET *bnet )
{
	CGHost :: EventBNETConnectTimedOut( bnet );
	OnBNETEvent( BNETEventTypeConnectTimeout, bnet );
}

void CGHostGenie :: EventBNETWhisper( CBNET *bnet, string user, string message )
{
	CGHost :: EventBNETWhisper( bnet, user, message );
	OnBNETMessage( BNETEventTypeWhisper, bnet, user, message );
}

void CGHostGenie :: EventBNETChat( CBNET *bnet, string user, string message )
{
	CGHost :: EventBNETChat( bnet, user, message );
	OnBNETMessage( BNETEventTypeChat, bnet, user, message );
}

void CGHostGenie :: EventBNETEmote( CBNET *bnet, string user, string message )
{
	CGHost :: EventBNETEmote( bnet, user, message );
	OnBNETMessage( BNETEventTypeEmote, bnet, user, message );
}

void CGHostGenie :: OnGameEvent( GameEventType type, CBaseGame *game)
{
	GameEventData data;
	data.event = type;
	data.game = game;
	if( gameCallback != NULL )
		gameCallback( callbackObject, data );
}

void CGHostGenie :: CreateGame( CMap *map, unsigned char gameState, bool saveGame, string gameName, string ownerName, string creatorName, string creatorServer, bool whisper )
{
	CBaseGame *oldGame = m_CurrentGame;
	CGHost :: CreateGame( map, gameState, saveGame, gameName, ownerName, creatorName, creatorServer, whisper );
	if( m_CurrentGame && oldGame != m_CurrentGame )
	{
		// new game was hosted
		OnGameEvent( GameEventTypeCreated, m_CurrentGame );
	}
}

void CGHostGenie :: EventGameDeleted( CBaseGame *game )
{
	CGHost :: EventGameDeleted( game );
	OnGameEvent( GameEventTypeDeleted, game );
}