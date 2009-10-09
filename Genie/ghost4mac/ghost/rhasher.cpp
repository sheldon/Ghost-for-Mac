/*
 *      rhasher.cpp
 *
 *      Copyright 2009 Lucas Romero
 *
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License as published by
 *      the Free Software Foundation; either version 2 of the License, or
 *      (at your option) any later version.
 *
 *      This program is distributed in the hope that it will be useful,
 *      but WITHOUT ANY WARRANTY; without even the implied warranty of
 *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *      GNU General Public License for more details.
 *
 *      You should have received a copy of the GNU General Public License
 *      along with this program; if not, write to the Free Software
 *      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *      MA 02110-1301, USA.
 */

#include "includes.h"
#include "rhasher.h"
#include "ghost.h"
#include "util.h"
#include <bncsutil/bncsutil.h>

struct sort_servers
{
	const bool operator()(const CRHServer *a, const CRHServer * b) const {
		// is "a" a better server than "b"? (means a<b)
		// there should never be any NULL pointers to sort, but just in case
		if (a == NULL) {
			return b == NULL;
		} else if (b == NULL) {
			return true;
		} else {
			return a->GetFailures( ) > b->GetFailures( );
		}
	}
};

CRemoteHasher :: CRemoteHasher( string username, string password, CGHost *ghost, string serverlist ) :
	m_Attempts( 0 ),
	m_Timeout( 5 ),
	m_ReconnectInterval( 2 ),
	m_NextConnectTime( GetTime( ) ),
	CBNCSUtilInterface(username, password)
{
	CONSOLE_Print( "[RHASH] creating remote hasher" );
	m_Socket = new CTCPClient( );
	m_GHost = ghost;
	SetServers( serverlist );
	CONSOLE_Print( "[RHASH] remote hasher created with " + UTIL_ToString( m_Servers.size( ) ) + " servers" );
}

CRemoteHasher :: ~CRemoteHasher( )
{
	if( m_Socket )
		delete m_Socket;
}

void CRemoteHasher :: ResetStatus( ) {
	if (m_Socket)
		m_Socket->Reset();
	m_Status = BNCSIdle;
}

unsigned int CRemoteHasher :: SetFD( void *fd, void *send_fd, int *nfds )
{
	if( !m_Socket /*|| m_Socket->HasError( )*/ )
		return 0;
	
	m_Socket->SetFD( (fd_set*)fd, (fd_set*)send_fd, nfds );
	return 1;
}

bool CRemoteHasher :: Update( void *fd, void *send_fd )
{
	if( !m_Socket )
		return true;

	switch (m_Status) {
		case BNCSIdle:
			return true;
		case BNCSConnecting:
			if ( m_Servers.size( ) == 0 )
			{
				CONSOLE_Print( "[RHASH] error: no server available" );
				m_Status = BNCSError;
			}
			else if( m_Attempts >= 3)
			{
				CONSOLE_Print( "[RHASH] failed to connect after 3 tries" );
				m_Status = BNCSError;
			}
			else if( !m_Socket->GetConnecting( ) && GetTime( ) >= m_NextConnectTime )
			{
				// attempt to connect
				sort(m_Servers.begin( ), m_Servers.end( ), sort_servers( ) );
				m_CurrentServer = m_Servers.front();
				m_NextConnectTime = GetTime( );
				
				CONSOLE_Print( "[RHASH: " + m_CurrentServer->GetName( ) + "] connecting to server (try #" + UTIL_ToString( m_Attempts ) + ")" );
				
				if( !m_GHost->m_BindAddress.empty( ) )
					CONSOLE_Print( "[RHASH: " + m_CurrentServer->GetName( ) + "] attempting to bind to address [" + m_GHost->m_BindAddress + "]" );
				
				m_Socket->Connect( m_GHost->m_BindAddress, m_CurrentServer->GetEndPoint( ), m_CurrentServer->GetPort( ) );
				if ( !m_CurrentServer->IsResolved( ) && !m_Socket->HasError( ) )
				{
					m_CurrentServer->SetServerIP( m_Socket->GetIPString( ) );
					CONSOLE_Print( "[RHASH: " + m_CurrentServer->GetName( ) + "] resolved and cached server IP address " + m_CurrentServer->GetEndPoint( ) );
				}
				else
					CONSOLE_Print( "[RHASH: " + m_CurrentServer->GetName( ) + "] using cached server IP address " + m_CurrentServer->GetEndPoint( ) );
			}
			else if( m_Socket->GetConnecting( ) )
			{
				// we are currently attempting to connect
				
				if( m_Socket->CheckConnect( ) )
				{
					CONSOLE_Print( "[RHASH: " + m_CurrentServer->GetName( ) + "] connected" );
					//m_WaitingToConnect = false;
					m_Status = BNCSConnected;
					unsigned char c = m_Request.size();
					BYTEARRAY b = UTIL_CreateByteArray(c);
					UTIL_AppendByteArrayFast( b, m_Request );
					m_Socket->PutBytes( b );
					m_Socket->DoSend( (fd_set*)send_fd );
				}
				else if( GetTime( ) >= m_NextConnectTime + m_Timeout )
				{
					// the connection attempt timed out
					CONSOLE_Print( "[RHASH: " + m_CurrentServer->GetName( ) + "] connect timed out (" + UTIL_ToString( m_Timeout ) + "s)" );
					m_Status = BNCSDisconnected;
				}
			}
			break;
		case BNCSConnected:
			if ( m_Socket->HasError( ) && m_CurrentServer)
			{
				CONSOLE_Print( "[RHASH: " + m_CurrentServer->GetName( ) + "] disconnected due to socket error" );
				m_Status = BNCSDisconnected;
			}
			else if( !m_Socket->GetConnecting( ) && !m_Socket->GetConnected( ) && m_CurrentServer)
			{
				// the socket was disconnected
				CONSOLE_Print( "[RHASH: " + m_CurrentServer->GetName( ) + "] disconnected due to socket not connected" );
				m_Status = BNCSDisconnected;
			}
			else if( m_Socket->GetConnected( ) )
			{
				m_Socket->DoRecv( (fd_set *)fd );
				ExtractAndProcessPackets( );
			}
			break;
		case BNCSDisconnected:
			m_NextConnectTime = GetTime( ) + m_ReconnectInterval;
			m_Socket->Reset( );
			m_CurrentServer->Failed( );
			m_Attempts++;
			m_Status = BNCSConnecting;
			CONSOLE_Print( "[RHASH: " + m_CurrentServer->GetName( ) + "] waiting " + UTIL_ToString( m_ReconnectInterval ) + " seconds to reconnect" );
			break;
		case BNCSError:
			//m_Socket->Disconnect( );
			m_Socket->Reset();
			m_Status = BNCSIdle;
			break;
		case BNCSSuccess:
			//m_Socket->Disconnect( );
			m_Socket->Reset();
			m_Status = BNCSIdle;
			break;
		default:
			m_Status = BNCSError;
			break;
	}
	return false;
}

void CRemoteHasher :: ExtractAndProcessPackets( )
{	
	string *RecvBuffer = m_Socket->GetBytes( );

	if (RecvBuffer->find('\n') != string::npos)
	{
		CONSOLE_Print( "[RHASH] got response" );
		//packet complete
		vector<string> values;

		char c='\t';
		string::const_iterator s = RecvBuffer->begin();
        while (true) {
            string::const_iterator begin = s;
			
            while (*s != c && s != RecvBuffer->end()) { ++s; }
			
			values.push_back(string(begin, s));
			
			if (s == RecvBuffer->end()) {
                break;
            }
			
            if (++s == RecvBuffer->end()) {
                //values.push_back("");
                break;
            }
        }
		
		//*RecvBuffer = string( );
		
		if (values.size( ) != 3)
		{
			CONSOLE_Print("[RHASH] invalid response: " + UTIL_ToString(values.size()) + " parameters");
			m_Status = BNCSDisconnected;
			return;
		}
		// number of data elements is valid
		
		uint32_t EXEVersion;
		uint32_t EXEVersionHash;
		
		stringstream ss;
		ss.str( values[0] );
		ss >> EXEVersion;
		if (ss.fail()) {
			CONSOLE_Print("[RHASH] invalid response: "+ values[0] +" is not valid for EXEVersion");
			m_Status = BNCSDisconnected;
			return;
		}
		
		m_EXEInfo = values[1];
		
		ss.clear( );
		ss.str( values[2] );
		ss >> EXEVersionHash;
		if (ss.fail()) {
			CONSOLE_Print("[RHASH] invalid response: "+ values[2] +" is not valid for EXEVersionHash");
			m_Status = BNCSDisconnected;
			return;
		}
		
		// process information
		m_EXEVersion = UTIL_CreateByteArray( EXEVersion, false );
		m_EXEVersionHash = UTIL_CreateByteArray( EXEVersionHash, false );
		m_KeyInfoROC = CreateKeyInfo( m_KeyROC, UTIL_ByteArrayToUInt32( m_ClientToken, false ), UTIL_ByteArrayToUInt32( m_ServerToken, false ) );
		m_KeyInfoTFT = CreateKeyInfo( m_KeyTFT, UTIL_ByteArrayToUInt32( m_ClientToken, false ), UTIL_ByteArrayToUInt32( m_ServerToken, false ) );
		
		m_Status = BNCSSuccess;
		CONSOLE_Print( "[RHASH] FINISHED!" );
	} else if( RecvBuffer->size( ) > 128 ) {
		// so much data and still no \n? something is wrong
		CONSOLE_Print("[RHASH] invalid response: too much data");
		m_Status = BNCSDisconnected;
	}
}

void CRemoteHasher :: SetServers( string serverlist )
{
	m_Servers.clear( );
	stringstream ss, parser;
	ss << serverlist;
	size_t pos;
	string server;
	
	while( ss.good( ) )
	{
		unsigned short port = 7070;
		ss >> server;
		if( ss.fail( ) )
			continue;
		
		pos = server.find( ":" );
		if( pos != string::npos && pos != server.size() )
		{
			parser.clear( );
			parser.str( server.substr( pos+1 ) );
			parser >> port;
		}
		m_Servers.push_back( new CRHServer( server.substr(0, pos), port ) );
	}
}

bool CRemoteHasher :: HELP_SID_AUTH_CHECK( string version, string keyROC, string keyTFT, string valueStringFormula, string mpqFileName, BYTEARRAY clientToken, BYTEARRAY serverToken )
{
	CONSOLE_Print( "[RHASH] initiating hash request" );
	m_KeyROC = keyROC;
	m_KeyTFT = keyTFT;
	m_ClientToken = clientToken;
	m_ServerToken = serverToken;
	m_Request = version + "\t" + UTIL_ToString( extractMPQNumber( mpqFileName.c_str( ) ) ) + "\t" + valueStringFormula + "\n";
	//m_WaitingToConnect = true;
	//m_Success = false;
	m_Status = BNCSConnecting;
}
