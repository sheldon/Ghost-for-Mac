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

#import "UIController.h"
#import	"LogEntry.h"
#import "MBPreferencesController.h"
#import "GHostController.h"

@implementation UIController


- (IBAction)selectFont:(id)sender {
    
}

// handle enter event from command input
- (BOOL)control: (NSControl *)control textView:(NSTextView *)textView doCommandBySelector: (SEL)commandSelector {
	//NSLog(@"entered control area = %@",NSStringFromSelector(commandSelector));
	if (commandSelector == @selector(insertNewline:)) {
		// pressed key was enter
		
	}
	return YES;
}





- (IBAction)showPreferences:(id)sender {
	[[MBPreferencesController sharedController] showWindow:sender];
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
		[output appendFormat:@"[%@ %@] %@\n",e.sender,[e.date descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],e.text];
	}
	[self copyToClipboard:output];
}

- (id)init
{
	[super init];
	//ConfigController *prefConfig = [[ConfigController alloc] initWithController:self];
	//TestMobileMeViewController *mobileMe = [[TestMobileMeViewController alloc] initWithNibName:@"PreferencesMobileMe" bundle:nil];
	
	//[prefConfig release];
	return self;
}
@end
