/*
 This file is part of Genie.
 Copyright 2009 Lucas Romero
 
 Genie is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Genie is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Genie.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "LogEntry.h"
#import <RegexKit/RegexKit.h>


@implementation LogEntry
@synthesize image;
@synthesize sender;
@synthesize text;
@synthesize date;
- (id)initWithText:(NSString*)newText sender:(NSString*)newSender date:(NSDate*)newDate image:(NSImage*)newImage {
	if (self = [super init]) {
		if (newImage == nil)
			newImage = [NSImage imageNamed:@"NSInfo"];
		self.text = newText;
		self.sender = newSender;
		self.date = newDate;
		self.image = newImage;
	}
	return self;
}
+ (id)logEntryWithText:(NSString*)text sender:(NSString*)sender date:(NSDate*)date image:(NSImage*)image {
	return [[LogEntry alloc] initWithText:text sender:sender date:date image:image];
}
+ (id)logEntryWithLine:(NSString*)line {
	NSString *sender = NULL;
	NSString *text = NULL;
	[line getCapturesWithRegexAndReferences:@"^\\[(.*?)\\](.*)",
	 @"$1", &sender, @"$2", &text,
	 nil];
	return [[LogEntry alloc] initWithText:text sender:sender date:[NSDate date] image:[NSImage imageNamed:[sender lowercaseString]]];
}
@end
