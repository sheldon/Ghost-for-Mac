/*	bnet-genie.cpp
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 28.03.10
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

/* HACK (approved by intel I was told :P)
 * we want to access protected members of the base class,
 * but damn C++ doesn't allow that :)
 */
#include "ghost.h"
#undef BNET_H
#define protected public
  #include "bnet.h"
#undef protected

#include "bnet-genie.h"
#include "ghost-genie.h"
#include "bncsutilinterface.h"
#include "bnlsclient.h"
#include "socket.h"
#include "bnetprotocol.h"
#include "commandpacket.h"
#include "bncsutilinterface-genie.h"
#include "util.h"


CBNETGenie :: CBNETGenie( CGHostGenie *ghost, const CBNET *bnet, bool interceptHashRequests)
: CBNET(ghost, bnet->m_Server, bnet->m_ServerAlias, bnet->m_BNLSServer, bnet->m_BNLSPort, bnet->m_BNLSWardenCookie,
		bnet->m_CDKeyROC, bnet->m_CDKeyTFT, bnet->m_CountryAbbrev, bnet->m_Country, bnet->m_LocaleID, bnet->m_UserName, bnet->m_UserPassword,
		bnet->m_FirstChannel, bnet->m_RootAdmin, bnet->m_CommandTrigger, bnet->m_HoldFriends, bnet->m_HoldClan, bnet->m_PublicCommands,
		bnet->m_War3Version, bnet->m_EXEVersion, bnet->m_EXEVersionHash, bnet->m_PasswordHashType, bnet->m_PVPGNRealmName,
		bnet->m_MaxMessageLength, bnet->m_HostCounterID ), m_InterceptHashRequests(interceptHashRequests), m_GHostGenie( ghost )
{
	
	delete m_BNCSUtil;
	m_BNCSUtilGenie = new CBNCSUtilInterfaceGenie( this, bnet->m_UserName, bnet->m_UserPassword );
	m_BNCSUtil = m_BNCSUtilGenie;
}

bool CBNETGenie :: InterceptPacket( CCommandPacket *packet )
{
	int sid = packet->GetID();
	switch (sid) {
		case CBNETProtocol :: SID_AUTH_INFO:
			// don't intercept if we shouldn't
			if( !m_InterceptHashRequests )
				return false;
			m_Protocol->RECEIVE_SID_AUTH_INFO( packet->GetData( ) );
			
			if( !m_BNCSUtilGenie->GenerateKeyInfo( m_GHost->m_TFT, m_CDKeyROC, m_CDKeyTFT, m_Protocol->GetClientToken( ), m_Protocol->GetServerToken( ) ) )
			{
				// error
				LogInfo( "[BNET: " + m_ServerAlias + "] logon failed - bncsutil key hash failed (check your Warcraft 3 cd keys), disconnecting" );
				m_Socket->Disconnect( );
			}
			else
			{
				// the Warden seed is the first 4 bytes of the ROC key hash
				// initialize the Warden handler
				
				if( !m_BNLSServer.empty( ) )
				{
					LogInfo( "[BNET: " + m_ServerAlias + "] creating BNLS client" );
					delete m_BNLSClient;
					m_BNLSClient = new CBNLSClient( this, m_BNLSServer, m_BNLSPort, m_BNLSWardenCookie );
					m_BNLSClient->QueueWardenSeed( UTIL_ByteArrayToUInt32( m_BNCSUtil->GetKeyInfoROC( ), false, 16 ) );
				}
				
				// call hash generating callback here
				// TODO: RoC only login
				LogInfo( "[GENIE] Got hash request" );
				
				BNETHashRequestData data;
				data.bnet = this;
				data.formula = m_Protocol->GetValueStringFormulaString( );
				data.verString = m_Protocol->GetIX86VerFileNameString( );
				m_GHostGenie->EventBNETHashRequest( data );
			}
			return true;
		case CBNETProtocol :: SID_FRIENDSLIST:
		{
			vector<CIncomingFriendList *> friends = m_Protocol->RECEIVE_SID_FRIENDSLIST( packet->GetData( ) );
			for( vector<CIncomingFriendList *> :: iterator i = friends.begin( ); i != friends.end( ); i++ )
			{
				m_GHostGenie->EventBNETIncomingFriend( this, (*i)->GetAccount( ), (*i)->GetDescription( ) );
			}
			break;
		}
		case CBNETProtocol :: SID_FRIENDSUPDATE:
		{
			// TODO: handle friends update
			break;
		}
		case CBNETProtocol :: SID_CLANMEMBERLIST:
		{
			vector<CIncomingClanList *> clans = m_Protocol->RECEIVE_SID_CLANMEMBERLIST( packet->GetData( ) );
			for( vector<CIncomingClanList *> :: iterator i = m_Clans.begin( ); i != m_Clans.end( ); i++ )
			{
				m_GHostGenie->EventBNETIncomingClanMember( this, (*i)->GetName( ), (*i)->GetDescription( ) );
			}
			break;
		}
		case CBNETProtocol :: SID_CLANMEMBERSTATUSCHANGE:
		{
			CIncomingClanList *clan = m_Protocol->RECEIVE_SID_CLANMEMBERSTATUSCHANGE( packet->GetData( ) );
			m_GHostGenie->EventBNETIncomingClanMember( this, clan->GetName( ), clan->GetDescription( ) );
			break;
		}
	}
	// don't intercept
	return false;
}

void CBNETGenie :: ExtractPackets( )
{
	// extract as many packets as possible from the socket's receive buffer and put them in the m_Packets queue
	
	string *RecvBuffer = m_Socket->GetBytes( );
	BYTEARRAY Bytes = UTIL_CreateByteArray( (unsigned char *)RecvBuffer->c_str( ), RecvBuffer->size( ) );
	
	// a packet is at least 4 bytes so loop as long as the buffer contains 4 bytes
	
	while( Bytes.size( ) >= 4 )
	{
		// byte 0 is always 255
		
		if( Bytes[0] == BNET_HEADER_CONSTANT )
		{
			// bytes 2 and 3 contain the length of the packet
			
			uint16_t Length = UTIL_ByteArrayToUInt16( Bytes, false, 2 );
			
			if( Length >= 4 )
			{
				if( Bytes.size( ) >= Length )
				{
					CCommandPacket *packet = new CCommandPacket( BNET_HEADER_CONSTANT, Bytes[1], BYTEARRAY( Bytes.begin( ), Bytes.begin( ) + Length ) );
					// if InterceptPacket() returns true, we don't want ProcessPackets() in CGHost base to process this particular packet
					if( !InterceptPacket( packet ) )
						m_Packets.push( packet );
					else
						delete packet;

					*RecvBuffer = RecvBuffer->substr( Length );
					Bytes = BYTEARRAY( Bytes.begin( ) + Length, Bytes.end( ) );
				}
				else
					return;
			}
			else
			{
				LogError( "[BNET: " + m_ServerAlias + "] error - received invalid packet from battle.net (bad length), disconnecting" );
				m_Socket->Disconnect( );
				return;
			}
		}
		else
		{
			LogError( "[BNET: " + m_ServerAlias + "] error - received invalid packet from battle.net (bad header constant), disconnecting" );
			m_Socket->Disconnect( );
			return;
		}
	}
}

void CBNETGenie :: QueueGameCreate( unsigned char state, string gameName, string hostName, CMap *map, CSaveGame *savegame, uint32_t hostCounter )
{
	CBNET :: QueueGameCreate( state, gameName, hostName, map, savegame, hostCounter );
	m_GHostGenie->EventBNETChatLeft( this );
}

void CBNETGenie :: QueueGameRefresh( unsigned char state, string gameName, string hostName, CMap *map, CSaveGame *saveGame, uint32_t upTime, uint32_t hostCounter )
{
	CBNET :: QueueGameRefresh( state, gameName, hostName, map, saveGame, upTime, hostCounter );
}

void CBNETGenie :: ProcessChatEvent( CIncomingChatEvent *chatEvent )
{
	CBNETProtocol :: IncomingChatEvent Event = chatEvent->GetChatEvent( );
	switch (Event) {
		case CBNETProtocol :: EID_CHANNEL:
			m_GHostGenie->EventBNETChannelJoined( this, chatEvent->GetUser( ) ,chatEvent->GetMessage( ) );
			break;
		case CBNETProtocol :: EID_JOIN:
			m_GHostGenie->EventBNETUserJoinedChannel( this, chatEvent->GetUser( ) ,chatEvent->GetMessage( ) );
			break;
		case CBNETProtocol :: EID_LEAVE:
			m_GHostGenie->EventBNETUserLeftChannel( this, chatEvent->GetUser( ) ,chatEvent->GetMessage( ) );
			break;
		//TODO: create seperate event for SHOWUSER
		case CBNETProtocol :: EID_SHOWUSER:
			m_GHostGenie->EventBNETUserJoinedChannel( this, chatEvent->GetUser( ) ,chatEvent->GetMessage( ) );
			break;
	}
	
	// someone may be freeing chatEvent's memory inside ProcessChatEvent(), so to be safe call base after we are done
	CBNET :: ProcessChatEvent( chatEvent );
}

void CBNETGenie :: ProcessFileHashes( string EXEInfo, uint32_t EXEVersion, uint32_t EXEVersionHash )
{
	m_BNCSUtilGenie->ProcessFileHashes( EXEInfo, EXEVersion, EXEVersionHash );
	m_Socket->PutBytes( m_Protocol->SEND_SID_AUTH_CHECK( m_GHost->m_TFT, m_Protocol->GetClientToken( ), m_BNCSUtil->GetEXEVersion( ), m_BNCSUtil->GetEXEVersionHash( ), m_BNCSUtil->GetKeyInfoROC( ), m_BNCSUtil->GetKeyInfoTFT( ), m_BNCSUtil->GetEXEInfo( ), "GHost" ) );
}