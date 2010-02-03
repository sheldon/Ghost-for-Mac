/*	ConfigEntry.h
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

#import <CoreData/CoreData.h>

@class BotLocal;

@interface ConfigEntry :  NSManagedObject  
{
	NSDictionary *valueDict;
}
- (BOOL)validateName:(id *)ioValue error:(NSError **)outError;
- (void)enableEntry;
- (void)disableEntry;
- (void)toggleEntry;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) BotLocal * bot;
@property (readonly) NSString * description;

@end



