/*
 *      rhasher.h
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

#ifndef RHASHER_H
#define RHASHER_H

#include "socket.h"
#include "util.h"
#include "bncsutilinterface.h"
#include <sstream>
#include <iostream>
using namespace std;
class CTCPClient;
class CGHost;

class CRHServer {
public:
	CRHServer( string address, int port ) { m_Address = address; m_Port = port; m_Failures = 0;}
	virtual string GetEndPoint( ) const { if ( !m_ServerIP.empty( ) ) return m_ServerIP; return m_Address; }
	virtual bool IsResolved( ) const { return !m_ServerIP.empty( ); }
	virtual string GetName( ) const { return m_Address + ":" + UTIL_ToString(m_Port); }
	virtual void SetServerIP( string ip ) { m_ServerIP = ip; }
	virtual int GetPort( ) const { return m_Port; }
	virtual int GetFailures( ) const { return m_Failures; }
	virtual void Failed( ) { m_Failures++; }
private:
	string m_Address;
	string m_ServerIP;
	int m_Port;
	int m_Failures;
};



class CRemoteHasher : public CBNCSUtilInterface
{
public:
	CRemoteHasher( string username, string password, CGHost *ghost, string serverlist );
	virtual ~CRemoteHasher( );
	unsigned int SetFD( void *fd, void *send_fd, int *nfds );
	bool Update( void *fd, void *send_fd );
	bool HELP_SID_AUTH_CHECK( string version, string keyROC, string keyTFT, string valueStringFormula, string mpqFileName, BYTEARRAY clientToken, BYTEARRAY serverToken );
	virtual void SetServers( string serverlist );
	virtual string GetErrorString( ) { return "logon failed - retrieving hash from server failed, disconnecting"; }
	virtual void ResetStatus( );
private:
	virtual void ExtractAndProcessPackets( );
	CGHost *m_GHost;
	string m_Request;
	
	CTCPClient *m_Socket;																					// the socket we use to communicate
	vector<CRHServer*> m_Servers;
	CRHServer *m_CurrentServer;

	uint32_t m_Timeout;
	uint32_t m_ReconnectInterval;
	uint32_t m_Attempts;
	uint32_t m_NextConnectTime;
	
	string m_KeyROC;
	string m_KeyTFT;
	
	BYTEARRAY m_ClientToken;
	BYTEARRAY m_ServerToken;
};


#endif