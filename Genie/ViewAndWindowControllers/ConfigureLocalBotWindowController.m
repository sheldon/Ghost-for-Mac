/*	ConfigureLocalBotWindowController.m
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 07.01.10
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

#import "ConfigureLocalBotWindowController.h"
#import "BotLocal.h"
#import "ConfigBoolValueTransformer.h"
#import "ConfigIntValueTransformer.h"
#import "ConfigEntry.h"

@implementation ConfigureLocalBotWindowController
@synthesize selectedBot;

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender {
    return [[[self selectedBot] managedObjectContext] undoManager];
}

- (IBAction)closeWindow:(id)sender
{
	[self.window endEditingFor:nil];
	[NSApp endSheet:self.window];
	[self close];
	//[NSApp endSheet:[self window]];
}

- (void)importConfigDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		[selectedBot importConfig:[importConfigPanel filename]];
	}
	[NSApp endSheet:sheet];
	[importConfigPanel release];
	importConfigPanel = nil;
}

- (IBAction)importConfig:(id)sender
{
	importConfigPanel = [[NSOpenPanel openPanel] retain];
	[importConfigPanel setTitle:@"Please select the config you want to import"];
	[importConfigPanel setCanChooseFiles:YES];
	[importConfigPanel setCanChooseDirectories:NO];
	
	[importConfigPanel setAllowedFileTypes:[NSArray arrayWithObject:@"cfg"]];
	[importConfigPanel setAllowsOtherFileTypes:NO];
	
	[importConfigPanel setAllowsMultipleSelection:NO];
	
	if ([importConfigPanel runModal]  == NSOKButton) {
		[selectedBot importConfig:[importConfigPanel filename]];
	}
	[importConfigPanel release];
	/*void (^snapshotOpenPanelHandler)(NSInteger) = ^( NSInteger result )
	{
		if (result == NSOKButton) {
			[selectedBot importConfig:[importConfigPanel filename]];
		}
		[importConfigPanel release];
		importConfigPanel = nil;
	};
	if (true || floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_5)
	{
		// User is using Mac OS X 10.5.X or earlier
		[panel beginSheetForDirectory:nil
								 file:nil
								types:nil
					   modalForWindow:[self window]
						modalDelegate:self
					   didEndSelector:@selector(importConfigDidEnd:
												returnCode:
												contextInfo:)
						  contextInfo:nil];
	}
	else	{
		// User is using Mac OS X 10.6 or higher

[importConfigPanel beginSheetModalForWindow:[self window] 
								  completionHandler:snapshotOpenPanelHandler];*/
	//}
}

- (IBAction)exportConfig:(id)sender
{
	
}

- (IBAction)addSetting:(id)sender
{
	[configSettings add:sender];
}

- (IBAction)removeSetting:(id)sender
{
	[configSettings remove:sender];
}

- (void)openLogFile:(NSString*)file
{
	NSLog(@"This should open this file: %@", file);
}

- (void)tableView:(NSTableView *)tableView
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)tableColumn
			  row:(NSInteger)row
{
    if (![[tableColumn identifier] isEqualToString: @"ValueTableValue"])
		return;
	ConfigEntry *data = [[configSettings arrangedObjects] objectAtIndex:row];
	NSString *type = nil;
	NSDictionary *keyDesc = [valueDescriptions valueForKey:data.name];
	if (keyDesc)
		type = [keyDesc valueForKey:@"type"];
	
	NSDictionary *options = nil;
	/*if ([type isEqualToString:@"uint"]) {
		//NSNumberFormatter *formatter = [[NSNumberFormatter new] autorelease];
		//[formatter setFormat:@"$#;0"];
		//[cell setFormatter:formatter];
		options =
		[NSDictionary dictionaryWithObject:@"ConfigIntValueTransformer"
									forKey:NSValueTransformerNameBindingOption];
		[cell bind: @"value" toObject:data withKeyPath: @"value" options: options];
	} else if ([cell isKindOfClass:[NSComboBoxCell class]]) {
		NSDictionary *keyDesc = [valueDescriptions valueForKey:data.name];
		options = [NSDictionary
				   dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], NSRaisesForNotApplicableKeysBindingOption,
				   @"Description missing", NSNotApplicablePlaceholderBindingOption,
				   nil];
		
		[cell bind:@"content" toObject:keyDesc withKeyPath:@"suggestions" options:nil];
		//[cell bind:@"contentObjects" toObject:keyDesc withKeyPath:@"suggestions.value" options:options];
		//[cell bind:@"contentValues" toObject:keyDesc withKeyPath:@"suggestions.value" options:options];
		
		[cell bind:@"value" toObject:data withKeyPath: @"value" options: nil];
	} else */if ([cell isKindOfClass:[NSPopUpButtonCell class]]) {
		NSDictionary *keyDesc = [valueDescriptions valueForKey:data.name];
		options = [NSDictionary
				   dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], NSRaisesForNotApplicableKeysBindingOption,
				   @"Description missing", NSNotApplicablePlaceholderBindingOption,
				   nil];

		[cell bind:@"content" toObject:keyDesc withKeyPath:@"options" options:nil];
		[cell bind:@"contentObjects" toObject:keyDesc withKeyPath:@"options.value" options:options];
		[cell bind:@"contentValues" toObject:keyDesc withKeyPath:@"options.title" options:options];

		[cell bind:@"selectedObject" toObject:data withKeyPath: @"value" options: nil];

	} else if ([cell isKindOfClass:[NSButtonCell class]]) {
		// boolean option
		options =
		[NSDictionary dictionaryWithObject:@"ConfigBoolValueTransformer"
									forKey:NSValueTransformerNameBindingOption];
		[cell bind: @"value" toObject:data withKeyPath: @"value" options: options];
	} else {
		// simple text
		[cell bind: @"value" toObject:data withKeyPath: @"value" options: nil];
		//[cell setEditable:YES];
	}
	
	[cell bind: @"enabled" toObject:data withKeyPath: @"enabled" options: nil];
} 

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([[tableColumn identifier] isEqualToString:@"ValueTableValue"]) {
		NSCell *dataCell = nil;
		ConfigEntry *data = [[configSettings arrangedObjects] objectAtIndex:row];
		NSString *name = data.name;
		NSDictionary *keyDesc = [valueDescriptions valueForKey:name];
		if (keyDesc) {
			NSString *type = [keyDesc valueForKey:@"type"];
			if (type) {
				if ([type isEqualToString:@"bool"]) {
					NSButtonCell *cellBool = [[NSButtonCell new] autorelease];
					[cellBool setButtonType:NSToggleButton];
					[cellBool setAlignment:NSLeftTextAlignment];
					[cellBool setImagePosition:NSImageLeft];
					[cellBool setTitle:nil];
					//[cellBool setImageScaling:NSImageScaleNone];
					[cellBool setBordered:NO];
					[cellBool setImage:[NSImage imageNamed:@"Off20"]];
					[cellBool setAlternateImage:[NSImage imageNamed:@"On20"]];
					dataCell = cellBool;
				} else if ([type isEqualToString:@"option"]) {
					NSPopUpButtonCell *cellPopUp = [[NSPopUpButtonCell new] autorelease];
					dataCell = cellPopUp;
				} /*else if ([type isEqualToString:@"suggestion"]) {
					NSComboBoxCell *cellComboBox = [[NSComboBoxCell new] autorelease];
					[cellComboBox setEditable:YES];
					[cellComboBox setSelectable:YES];
					//[cellComboBox setItemHeight:7];
					[cellComboBox setFont:[NSFont fontWithDescriptor:[[cellComboBox font] fontDescriptor] size:11]];
					//[cellComboBox setControlSize:NSSmallControlSize];
					
					dataCell = cellComboBox;
				} else if ([type isEqualToString:@"uint"]) {
					NSStepperCell *stepperCell = [[NSStepperCell new] autorelease];
					[stepperCell setMinValue:0];
					[stepperCell setMaxValue:-1];
					dataCell = stepperCell;
				}*/
			}
		}
		
		if (!dataCell)
			dataCell = [tableColumn dataCell];
		[dataCell setEditable:YES];
		return dataCell;
	}
	// by default return nil to present NSTextFieldCell
	return [tableColumn dataCell];
}

- (void)awakeFromNib
{
	NSString *plistFile = [[NSBundle mainBundle] pathForResource:@"ConfigValueDescriptions"
														  ofType:@"plist"];
	valueDescriptions =	[[NSDictionary dictionaryWithContentsOfFile:plistFile] retain];
}

- (id)init
{
	if (self = [super initWithWindowNibName:@"ConfigureLocalBot"]) {
		ConfigBoolValueTransformer *valueTransformer = [[[ConfigBoolValueTransformer
														alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:valueTransformer
										forName:@"ConfigBoolValueTransformer"];
		
		ConfigIntValueTransformer *intValueTransformer = [[[ConfigIntValueTransformer
														  alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:intValueTransformer
										forName:@"ConfigIntValueTransformer"];	
	}
	return self;
}

/*- (BOOL)validateToolbarItem:(NSToolbarItem *)item {
	NSArray *alwaysOn = [NSArray arrayWithObjects:@"ImportConfig",@"ExportConfig",nil];
	if ([alwaysOn containsObject:[item itemIdentifier]])
		return YES;
	NSArray *advancedItems = [NSArray arrayWithObjects:@"AddSetting",@"RemoveSetting",@"ImportConfig",@"ExportConfig",nil];
    if ([[[configSection selectedTabViewItem] identifier] isEqualToString:@"Advanced"]) {
		if ([advancedItems containsObject:[item itemIdentifier]])
			return YES;
		return NO;
	}
	return NO;
}*/
@end
