/*	ConfigEntry.m
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 08.01.10
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

#import "ConfigEntry.h"

#import "BotLocal.h"

@implementation ConfigEntry 

@dynamic value;
@dynamic enabled;
@dynamic name;
@dynamic bot;

- (void)toggleEntry
{
	BOOL current = [self.enabled boolValue];
	self.enabled = [NSNumber numberWithBool:!current];
}

- (void)enableEntry
{
	self.enabled = [NSNumber numberWithBool:YES];
}
- (void)disableEntry
{
	self.enabled = [NSNumber numberWithBool:NO];
}

- (BOOL)validateForInsert:(NSError **)error
{
	return YES;
}

- (BOOL)validateName:(id *)ioValue error:(NSError **)outError
{
	NSEnumerator *e = [[[self bot] settings] objectEnumerator];
	NSString *newValue = *ioValue;
	ConfigEntry *entry;
	while (entry = [e nextObject]) {
		if (entry != self && [[entry name] isEqualToString:newValue]) {
			[entry disableEntry];
			[self enableEntry];
			/*if (outError != NULL) {
				NSString *errorStr = NSLocalizedStringFromTable(
																@"Value name does already exist", @"ConfigEntry",
																@"validation: duplicate name error");
				NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorStr
																		 forKey:NSLocalizedDescriptionKey];
				NSError *error = [[[NSError alloc] initWithDomain:@"ConfigEntry"
															 code:1
														 userInfo:userInfoDict] autorelease];
				*outError = error;
			}*/
			//return NO;
		}
	}
	
	return YES;
}

@end
