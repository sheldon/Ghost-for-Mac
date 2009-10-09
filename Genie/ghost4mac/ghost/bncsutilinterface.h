/*

   Copyright [2008] [Trevor Hogan]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   CODE PORTED FROM THE ORIGINAL GHOST PROJECT: http://ghost.pwner.org/

*/

#ifndef BNCSUTIL_INTERFACE_H
#define BNCSUTIL_INTERFACE_H

//
// CBNCSUtilInterface
//

enum HashStatus
{
	BNCSIdle,
	BNCSConnecting,
	BNCSConnected,
	BNCSDisconnected,
	BNCSSuccess,
	BNCSError,
};

class CBNCSUtilInterface
{
protected:
	void *m_NLS;
	BYTEARRAY m_EXEVersion;			// set in HELP_SID_AUTH_CHECK
	BYTEARRAY m_EXEVersionHash;		// set in HELP_SID_AUTH_CHECK
	string m_EXEInfo;				// set in HELP_SID_AUTH_CHECK
	BYTEARRAY m_KeyInfoROC;			// set in HELP_SID_AUTH_CHECK
	BYTEARRAY m_KeyInfoTFT;			// set in HELP_SID_AUTH_CHECK
	BYTEARRAY m_ClientKey;			// set in HELP_SID_AUTH_ACCOUNTLOGON
	BYTEARRAY m_M1;					// set in HELP_SID_AUTH_ACCOUNTLOGONPROOF
	BYTEARRAY m_PvPGNPasswordHash;	// set in HELP_PvPGNPasswordHash

public:
	CBNCSUtilInterface( string userName, string userPassword );
	~CBNCSUtilInterface( );

	BYTEARRAY GetEXEVersion( )								{ return m_EXEVersion; }
	BYTEARRAY GetEXEVersionHash( )							{ return m_EXEVersionHash; }
	string GetEXEInfo( )									{ return m_EXEInfo; }
	BYTEARRAY GetKeyInfoROC( )								{ return m_KeyInfoROC; }
	BYTEARRAY GetKeyInfoTFT( )								{ return m_KeyInfoTFT; }
	BYTEARRAY GetClientKey( )								{ return m_ClientKey; }
	BYTEARRAY GetM1( )										{ return m_M1; }
	BYTEARRAY GetPvPGNPasswordHash( )						{ return m_PvPGNPasswordHash; }

	void SetEXEVersion( BYTEARRAY &nEXEVersion )			{ m_EXEVersion = nEXEVersion; }
	void SetEXEVersionHash( BYTEARRAY &nEXEVersionHash )	{ m_EXEVersionHash = nEXEVersionHash; }

	virtual void Reset( string userName, string userPassword );
	virtual bool Update( void *fd, void *send_fd ) { return false; }
	virtual unsigned int SetFD( void *fd, void *send_fd, int *nfds ) { return 0; }
	virtual bool HELP_SID_AUTH_CHECK( string war3Path, string keyROC, string keyTFT, string valueStringFormula, string mpqFileName, BYTEARRAY clientToken, BYTEARRAY serverToken );
	virtual bool HELP_SID_AUTH_ACCOUNTLOGON( );
	virtual bool HELP_SID_AUTH_ACCOUNTLOGONPROOF( BYTEARRAY salt, BYTEARRAY serverKey );
	virtual bool HELP_PvPGNPasswordHash( string userPassword );
	HashStatus GetStatus( ) const { return m_Status; }
	virtual void ResetStatus( ) { m_Status = BNCSIdle; }
	virtual string GetErrorString( ) { return "logon failed - bncsutil key hash failed (check your Warcraft 3 path and cd keys), disconnecting"; }
protected:
	HashStatus m_Status;
	BYTEARRAY CreateKeyInfo( string key, uint32_t clientToken, uint32_t serverToken );
};

#endif
