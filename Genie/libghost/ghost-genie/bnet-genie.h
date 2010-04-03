/*	bnet-genie.h
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

#ifndef CBNETGENIE_H
#define CBNETGENIE_H

#include "bnet.h"

class CBNET;
class CGHostGenie;
class CBNCSUtilInterfaceGenie;

class CBNETGenie : public CBNET
{
protected:
	bool m_InterceptHashRequests;
	CBNCSUtilInterfaceGenie *m_BNCSUtilGenie;
	CGHostGenie *m_GHostGenie;
public:
	/*CBNETGenie( CGHost *nGHost, string nServer, string nServerAlias, string nBNLSServer, uint16_t nBNLSPort, uint32_t nBNLSWardenCookie,
						  string nCDKeyROC, string nCDKeyTFT, string nCountryAbbrev, string nCountry, uint32_t nLocaleID, string nUserName, string nUserPassword,
						  string nFirstChannel, string nRootAdmin, char nCommandTrigger, bool nHoldFriends, bool nHoldClan, bool nPublicCommands,
						  unsigned char nWar3Version, BYTEARRAY nEXEVersion, BYTEARRAY nEXEVersionHash, string nPasswordHashType, string nPVPGNRealmName,
						  uint32_t nMaxMessageLength, uint32_t nHostCounterID );*/
	CBNETGenie( CGHostGenie* ghost, const CBNET *bnet, bool interceptHashRequests);
	virtual void ExtractPackets( );
	virtual bool InterceptPacket( CCommandPacket *packet );
	virtual void ProcessChatEvent( CIncomingChatEvent *chatEvent );
	virtual void QueueGameCreate( unsigned char state, string gameName, string hostName, CMap *map, CSaveGame *saveGame, uint32_t hostCounter );
	virtual void QueueGameRefresh( unsigned char state, string gameName, string hostName, CMap *map, CSaveGame *saveGame, uint32_t upTime, uint32_t hostCounter );
	void ProcessFileHashes( string EXEInfo, uint32_t EXEVersion, uint32_t EXEVersionHash );
};

#endif