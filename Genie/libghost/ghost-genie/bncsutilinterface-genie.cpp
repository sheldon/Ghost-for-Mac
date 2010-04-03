/*	bncsutilinterface-genie.cpp
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

#include "bncsutilinterface-genie.h"
#include "bncsutilinterface.h"
#include "util.h"

CBNCSUtilInterfaceGenie ::  CBNCSUtilInterfaceGenie( CBNET *bnet, string userName, string userPassword )
	: CBNCSUtilInterface( bnet, userName, userPassword)
{
	
}

bool CBNCSUtilInterfaceGenie :: GenerateKeyInfo( bool TFT, string keyROC, string keyTFT, BYTEARRAY clientToken, BYTEARRAY serverToken )
{
	m_KeyInfoROC = CreateKeyInfo( keyROC, UTIL_ByteArrayToUInt32( clientToken, false ), UTIL_ByteArrayToUInt32( serverToken, false ) );
	
	if( TFT )
		m_KeyInfoTFT = CreateKeyInfo( keyTFT, UTIL_ByteArrayToUInt32( clientToken, false ), UTIL_ByteArrayToUInt32( serverToken, false ) );
	
	if( m_KeyInfoROC.size( ) == 36 && ( !TFT || m_KeyInfoTFT.size( ) == 36 ) )
		return true;
	else
	{
		if( m_KeyInfoROC.size( ) != 36 )
			CONSOLE_Print( "[BNCSUI] unable to create ROC key info - invalid ROC key" );
		
		if( TFT && m_KeyInfoTFT.size( ) != 36 )
			CONSOLE_Print( "[BNCSUI] unable to create TFT key info - invalid TFT key" );
	}
	// error
	return false;
}

void CBNCSUtilInterfaceGenie :: ProcessFileHashes( string EXEInfo, uint32_t EXEVersion, uint32_t EXEVersionHash )
{
	m_EXEInfo = EXEInfo;
	m_EXEVersion = UTIL_CreateByteArray( EXEVersion, false );
	m_EXEVersionHash = UTIL_CreateByteArray( EXEVersionHash, false );
}