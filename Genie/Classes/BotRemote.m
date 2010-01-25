/*	BotLocal.m
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 01.01.10
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

#import "BotRemote.h"


@implementation BotRemote
- (void)start
{
	[self willChangeValueForKey:@"running"];
	[self setPrimitiveValue:[NSNumber numberWithBool:YES] forKey:@"running"];
	[self didChangeValueForKey:@"running"];
}
- (void)stop
{
	[self willChangeValueForKey:@"running"];
	[self setPrimitiveValue:[NSNumber numberWithBool:NO] forKey:@"running"];
	[self didChangeValueForKey:@"running"];
}
- (void)startStop
{
	[self willAccessValueForKey:@"running"];
	BOOL _running = [[self primitiveValueForKey:@"running"] boolValue];
	[self didAccessValueForKey:@"running"];
	if (_running)
		[self stop];
	else
		[self start];
}
@end
