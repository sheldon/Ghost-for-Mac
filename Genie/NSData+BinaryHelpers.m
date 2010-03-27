/*	NSDataHelpers.m
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 08.02.10
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

#import "NSData+BinaryHelpers.h"


@implementation NSData (BinaryHelpers)

- (uint32_t)getInt32OffsetIncrement:(NSUInteger *)offset {
	
	uint32_t unused;
	NSRange myRange = NSMakeRange(*offset, sizeof(unused));
	[self getBytes:&unused range:myRange];
	*offset += sizeof(unused);
	return CFSwapInt32LittleToHost(unused);
}

- (uint16_t)getInt16OffsetIncrement:(NSUInteger *)offset {
	
	uint16_t unused;
	NSRange myRange = NSMakeRange(*offset, sizeof(unused));
	[self getBytes:&unused range:myRange];
	*offset += sizeof(unused);
	return CFSwapInt16LittleToHost(unused);
}

- (uint8_t)getByteOffsetIncrement:(NSUInteger *)offset {
	
	uint8_t unused;
	NSRange myRange = NSMakeRange(*offset, sizeof(unused));
	[self getBytes:&unused range:myRange];
	*offset += sizeof(unused);
	return unused;
}



@end
