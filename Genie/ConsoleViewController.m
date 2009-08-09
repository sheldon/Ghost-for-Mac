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

#import "ConsoleViewController.h"
#import "LogEntry.h"
#import "GHostSocket.h"
#import <QuartzCore/QuartzCore.h>
#import	<QuartzCore/CAAnimation.h>


@implementation ConsoleViewController
@synthesize logLines=_logLines;
@synthesize autoScroll;
/*- (CAAnimation *)animationForKey:(NSString *)key
{
	if (key)
		NSLog(@"KEY: %@", key);
	return [CABasicAnimation animationWithKeyPath:@"nil"];
}*/
/*-(id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key
{
	if (key)
		NSLog(@"KEY: %@", key);
	if (layer)
		NSLog(@"LAYER: %@", layer);
	//if (key != @"onDraw")
	//	return [NSNull null];
	return [[consoleTable layer] actionForLayer:layer forKey:key];
}*/
- (NSPredicate*)filterPredicate
{
	NSLog(@"11111111111111");

	return [listController filterPredicate];
}
- (void)setFilterPredicate:(NSPredicate*)value
{
	NSLog(@"22222222222222");
	[listController setFilterPredicate:value];
}
- (NSString *)title
{
	return NSLocalizedString(@"Console", @"Title of 'Console' view");
}

- (NSString *)identifier
{
	return @"ConsoleView";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"ghost.png"];
}

- (IBAction)inputCommand:(id)sender {
	NSLog([sender stringValue]);
	[[GHostSocket sharedSocket] sendCommand:[sender stringValue]];
	[sender setStringValue:@""];
}

- (void)contextMenuSelected:(id)sender {
	BOOL on = ([sender state] == NSOnState);
	[sender setState:on ? NSOffState : NSOnState];
	NSTableColumn *column = [sender representedObject];
	[column	setHidden:on];
}

-(void)copyToClipboard:(NSString*)str
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
    [pb declareTypes:types owner:self];
    [pb setString: str forType:NSStringPboardType];
}

- (IBAction)copyLines:(id)sender {
	NSMutableString* output = [NSMutableString string];
	for (LogEntry *e in [listController selectedObjects]) {
		[output appendFormat:@"[%@] [%@] %@\n", [e.date descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil], e.sender,e.text];
	}
	[self copyToClipboard:output];
}

- (void)awakeFromNib
{
	[[consoleTable layer] setDelegate:self];
	[[consoleTable layer] removeAllAnimations];
	NSMenu *showHideHeaderMenu = [[NSMenu alloc] initWithTitle:@"Show/hide columns"];
	for (NSTableColumn *column in [consoleTable tableColumns]) {
		NSString *title = [[column headerCell] title];
		NSMenuItem *item = [showHideHeaderMenu addItemWithTitle:title action:@selector(contextMenuSelected:) keyEquivalent:@""];
		[item setTarget:self];
		[item setRepresentedObject:column];
		
		if([column isHidden])
			[item setState:NSOffState];
		else
			[item setState:NSOnState];
	}
	[[consoleTable headerView] setMenu:showHideHeaderMenu];
}

- (void)addCoreOutput:(NSString*)msg// autoScroll:(BOOL)scroll
{
	NSInteger count = [[listController arrangedObjects] count];
	[listController addObject:[LogEntry logEntryWithLine:msg]];
	NSInteger newcount = [[listController arrangedObjects] count];
	if (newcount > count && autoScroll)
		[consoleTable scrollRowToVisible:newcount - 1];
}

- (id)init
{
	self = [self initWithNibName:@"ViewConsole" bundle:nil];
	_logLines = [NSMutableArray arrayWithObject:[LogEntry logEntryWithText:@"Genie started" sender:@"GENIE" date:[NSDate date] image:[NSImage imageNamed:@"ghost.png"]]];
	autoScroll = YES;
	return self;
}
@end
