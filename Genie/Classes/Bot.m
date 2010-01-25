/*	Bot.m
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 06.01.10
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

#import "Bot.h"


@implementation Bot 

@dynamic autoStart;
@dynamic name;
@dynamic hostPort;
@dynamic adminCount;
@dynamic version;
@dynamic comment;
@dynamic running;
@dynamic messages;
@dynamic games;
@dynamic servers;

- (void)awakeFromFetch
{
	if ([self.autoStart boolValue]) {
		[self start];
	}
}
-(void)start
{
}
-(void)stop
{
}
-(void)startStop
{
}
- (void)sendCommand:(NSDictionary *)cmd
{
}
- (NSNumber*)running
{
	return [NSNumber numberWithBool:NO];
}

@end
