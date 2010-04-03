/*	User.m
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

#import "User.h"
#import "FriendInfo.h"


@implementation User 

@dynamic name;
@dynamic server;
@dynamic channel;
@dynamic messages;
@dynamic clanInfo;
@dynamic friendInfo;

static NSImage *friendImage = nil;

- (void)awakeFromFetch
{
	friendImage = nil;
}

+ (NSImage*)getFriendImage
{
	if (!friendImage)
	{
		NSImage * userImg = [NSImage imageNamed:NSImageNameUser];
		NSImage * favImg = [NSImage imageNamed:@"heart32.png"];
		NSImage * compositeImage;
		
		NSRect rect = { 0,0, 32, 32};
		NSSize compositeSize = rect.size;
		
		compositeImage = [[NSImage alloc] initWithSize:compositeSize];
		
		[compositeImage lockFocus];
		
		// this image has its own graphics context, so
		// we need to specify high interpolation again	
		[[NSGraphicsContext currentContext]
		 setImageInterpolation: NSImageInterpolationHigh];
		
		[userImg drawInRect: rect
				   fromRect: NSZeroRect
				  operation: NSCompositeSourceOver
				   fraction: 1.0];
		
		NSRect rect2 = { 15, 15 , 16, 16};
		[favImg drawInRect: rect2
				  fromRect: NSZeroRect
				 operation: NSCompositeSourceOver
				  fraction: 1.0];
		
		
		
		[compositeImage unlockFocus];
		friendImage = compositeImage;
	}
	
	return friendImage;
}

- (NSImage*)icon
{
	if (self.friendInfo)
	{
		return [User getFriendImage];
	}
	return [NSImage imageNamed:NSImageNameUser];
}

@end
