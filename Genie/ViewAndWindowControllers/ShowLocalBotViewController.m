/*	ShowLocalBotViewController.m
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

#import "ShowLocalBotViewController.h"
#import "BotLocal.h"
#import "Server.h"
#import "ConsoleMessage.h"

@implementation ShowLocalBotViewController
@synthesize selectedBot;

- (NSInteger)selectedMode
{
	return [tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
}

- (void)setSelectedMode:(NSInteger)value
{
	[tabView selectTabViewItemAtIndex:value];
}

- (void)awakeFromNib
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"date" ascending:NO];
	[messageController setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
}
- (id)init
{
	if (self = [super initWithNibName:@"ShowLocalBotView" bundle:nil]) {
		selectedBot = nil;
	}
	return self;
}

-(void)copyToClipboard:(NSString*)str
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
    [pb declareTypes:types owner:self];
    [pb setString: str forType:NSStringPboardType];
}

- (IBAction)copyLines:(id)sender
{
	NSMutableString* output = [NSMutableString string];
	for (ConsoleMessage *m in [messageController selectedObjects]) {
		[output appendFormat:@"[%@] %@\n", [m.date descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil], m.text];
	}
	[self copyToClipboard:output];
}

- (IBAction)execCommand:sender
{
	NSString *cmd = [sender stringValue];
	Server* server = [[serverController selectedObjects] lastObject];
	if (server) {
		[selectedBot.botInterface execCommand:[NSDictionary dictionaryWithObjectsAndKeys:
								  cmd, @"command",
								  server, @"server",
								  nil]];
		[sender setStringValue:@""];
	}
}
@end
