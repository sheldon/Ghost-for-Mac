/*	NSMutableData+W3GSHelpers.m
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

#import "NSMutableData+BinaryHelpers.h"


@implementation NSMutableData (BinaryHelpers)
- (void)setW3GSPacketLength
{
	uint16_t size = [self length];
	size = CFSwapInt16HostToLittle(size);
	
	NSRange range;
	range.location = 2;
	range.length = sizeof(size);
	
	[self replaceBytesInRange:range withBytes:&size];
}
- (void)appendUInt16:(uint16_t)value
{
	value = CFSwapInt16HostToLittle(value);
	[self appendBytes:&value length:sizeof(value)];
}
- (void)appendByte:(uint8_t)value
{
	//value = CFSwapInt16HostToLittle(value);
	[self appendBytes:&value length:sizeof(value)];
}
- (void)appendUInt32:(uint32_t)value
{
	value = CFSwapInt32HostToLittle(value);
	[self appendBytes:&value length:sizeof(value)];
}

@end
