/*	bncsutilinterface-genie.h
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

#ifndef BNCSUTILINTERFACEGENIE_H
#define BNCSUTILINTERFACEGENIE_H

#include "ghost.h"
#include "bnet.h"
#include "bncsutilinterface.h"

class CBNCSUtilInterfaceGenie : public CBNCSUtilInterface
{
public:
	CBNCSUtilInterfaceGenie( CBNET *bnet, string userName, string userPassword );
	bool GenerateKeyInfo( bool TFT, string keyROC, string keyTFT, BYTEARRAY clientToken, BYTEARRAY serverToken );
	void ProcessFileHashes( string EXEInfo, uint32_t EXEVersion, uint32_t EXEVersionHash );
};

#endif