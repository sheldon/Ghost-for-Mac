//
//  ChatViewController.m
//  Genie
//
//  Created by Lucas on 15.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChatViewController.h"
#import "RegexKit/RegexKit.h"
#import "ChatMessage.h"
#import "GHostSocket.h"


@implementation ChatViewController
@synthesize messages=_messages;
@synthesize autoScroll;
@synthesize chatFilter;
- (void)updatePredicate
{
	//NSString *pred = [NSString string];
	NSPredicate *pred;// = [NSPredicate predicateWithValue:YES];
	if (hideCommands)
	{
		pred = [NSPredicate predicateWithFormat:@"isCommand == NO || isVirtualMessage == YES"];
	}
	else
		pred = [NSPredicate predicateWithFormat:@"isVirtualMessage == NO"];
	self.chatFilter = pred;
	//[listController setFilterPredicate:pred];
	//[listController rearrangeObjects];
}
- (BOOL)hideCommands
{
	return hideCommands;
}

- (void)awakeFromNib
{
	//[self loadView];
	//[self updatePredicate];
	//ChatMessage *msg = [ChatMessage chatMessageWithText:@"test" sender:@"nobody" date:[NSDate date] image:favIcon];
	//[self addMessage:msg];
}
- (void)setHideCommands:(BOOL)value
{
	if (hideCommands == value)
		return;
	hideCommands = value;
	[self updatePredicate];
}
- (NSString *)title
{
	return NSLocalizedString(@"Chat", @"Title of 'Chat' view");
}

- (NSString *)identifier
{
	return @"ChatView";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"ghost.png"];
}

- (id)init
{
	self = [self initWithNibName:@"ViewChat" bundle:nil];
	_messages = [NSMutableArray array];
	commandTriggers = [NSMutableDictionary dictionary];
	hideCommands = YES;
	autoScroll = YES;
	[self updatePredicate];
	
	
	/*favIcon = [[NSImage alloc] initWithSize:NSMakeSize(32, 32)];
	NSImage *image1 = [NSImage imageNamed:NSImageNameEveryone];
	NSImage *image2 = [NSImage imageNamed:@"heart32.png"];
	favIcon = image2;*/
	/*[image2 setSize:NSMakeSize(20, 20)];
	[favIcon lockFocus];
	[image1 compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
	[image2 compositeToPoint:NSMakePoint(14,0) operation:NSCompositeSourceOver];
	[favIcon unlockFocus];*/
	
	return self;
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
	for (ChatMessage *e in [listController selectedObjects]) {
		[output appendFormat:@"[%@] [%@] %@\n", [e.date descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil], e.sender,e.text];
	}
	[self copyToClipboard:output];
}

- (void)addMessage:(ChatMessage *)msg
{
	if (!msg)
		return;
	//NSLog(@"canInsert: %d", [listController canInsert]);
	NSInteger count = [[listController arrangedObjects] count];
	[listController addObject:msg];
	//TODO: this sucks! why do we have to clear the filterPredicate upon adding new items?
	[self updatePredicate];
	NSInteger newcount = [[listController arrangedObjects] count];
	if (newcount > count && autoScroll)
		[messageTable scrollRowToVisible:newcount - 1];
}

- (IBAction)inputCommand:(id)sender {
	NSLog(@"%@", [sender stringValue]);
	[[GHostSocket sharedSocket] sendCommand:[@"say " stringByAppendingString:[sender stringValue]]];
	
	/*ChatMessage *msg = [ChatMessage chatMessageWithText:[sender stringValue] sender:@"Me" date:[NSDate date] image:nil];
	msg.image = [NSImage imageNamed:NSImageNameEveryone];
	msg.isVirtualMessage = YES;
	[self addMessage:msg];*/
	[sender setStringValue:@""];
}

// handle enter event from command input
- (BOOL)control: (NSControl *)control textView:(NSTextView *)textView doCommandBySelector: (SEL)commandSelector {
	//NSLog(@"entered control area = %@",NSStringFromSelector(commandSelector));
	if (commandSelector == @selector(insertTab:)) {
		// pressed key was tab
		NSLog(@"TAB pressed!");
		return YES;
	}
	return NO;
}

const NSString *reCommandTrigger = @"^\\[GHOST\\] using commandtrigger \\[(.*?)\\] for server \\[(.*?)\\]";
const NSString *reAdminSays = @"^\\[BNET: (.*?)\\] admin \\[(.*?)\\] sent command \\[(.)say (.*?)\\]$";
//const NSString *reWhisper = @"(?m)^\\[WHISPER: (.*?)\\] \\[(.*?)\\] (.*?)$";
const NSString *reMessage = @"(?m)^\\[(LOCAL|WHISPER): (.*?)\\] \\[(.*?)\\] (.*?)$";

- (void)parseConsoleOutput:(NSString*)line
{
	NSString *group1 = nil;
	NSString *group2 = nil;
	NSString *group3 = nil;
	NSString *group4 = nil;
	ChatMessage *msg = nil;
	
	if ([line getCapturesWithRegexAndReferences:reCommandTrigger, @"$1", &group1, @"$2", &group2, nil]) {
		[commandTriggers setValue:group1 forKey:group2];
		NSLog(@"Got command trigger '%@' for server '%@'", group1, group2);
	}
	else if ([line getCapturesWithRegexAndReferences:reMessage, @"$1", &group1, @"$2", &group2, @"$3", &group3, @"$4", &group4, nil]) {
		msg = [ChatMessage chatMessageWithText:group4 sender:group3 date:[NSDate date] image:nil];
		if ([group1 isEqualToString:@"WHISPER"]) {
			msg.isWhisper = YES;
			msg.image = [NSImage imageNamed:NSImageNameUser];
		} else {
			msg.image = [NSImage imageNamed:NSImageNameEveryone];
		}
		msg.realm = group2;
		NSString *realm = [commandTriggers valueForKey:group2];
		if (realm != nil && [group4 hasPrefix:realm])
			msg.isCommand = YES;
	}
	else if ([line getCapturesWithRegexAndReferences:reAdminSays, @"$1", &group1, @"$2", &group2, @"$3", &group3, @"$4", &group4, nil]) {
		if ([group3 isEqualToString:[commandTriggers valueForKey:group1]]) {
			msg = [ChatMessage chatMessageWithText:group4 sender:group2 date:[NSDate date] image:nil];
			msg.realm = group1;
			msg.isVirtualMessage = YES;
			msg.image = [NSImage imageNamed:NSImageNameEveryone];
		}
	}
	if (msg && msg.isVirtualMessage && [msg.text hasPrefix:@"/f m "]) {
		msg.text = [msg.text substringFromIndex:5];
		
	}
	
	if (msg) {
		//msg.image = favIcon;
		[self addMessage:msg];
		
	}
}

- (CGFloat)tableView:(NSTableView *)tv heightOfRow:(NSInteger)row
{
	// Get column for Tweet Status
	NSTableColumn *column = [tv tableColumnWithIdentifier:@"message"];
	// Create a copy of the relevant cell - retains text attributes.
	NSCell *cell = [[column dataCellForRow:row] copyWithZone:NULL];
	// Retrieve stringvalue from XML Data
	//NSXMLNode *node = [itemNodes objectAtIndex:row];
	[cell setStringValue:[[[listController arrangedObjects] objectAtIndex:row] text]];
	// Calculate height using cellSizeForBounds, limiting it to width of column. 
	// Add 10 pixels for padding.
	CGFloat height = [cell cellSizeForBounds:
					  NSMakeRect(0.0, 0.0, [column width], 
								 1000.0)].height/*+10.0*/;
	// Profile pics are 48x48, so ensure these are fully visible with >=10px padding 
	//height = MAX(height,58.0);
	// Release the cell copy.
	[cell release];
	return height;
}
@end
