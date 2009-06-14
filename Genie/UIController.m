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

@implementation UIController
- (IBAction)editConfig:(id)sender {
	//NSRunAlertPanel(@"Close Document", 
	//				[[configSelector selectedItem] title],
	//				@"OK", @"Cancel", /*ThirdButtonHere:*/nil
	//				/*, args for a printf-style msg go here */);
	NSString* file = [[ghostController configDir] stringByAppendingPathComponent: [[configSelector selectedItem] title]];
	[textEdit readRTFDFromFile: file];
	/*NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	if (![workspace openFile:file])
		NSRunAlertPanel(@"File Error", 
						@"Could not open config file '%@'\nFile not found or no file handler defined?",
						@"OK", nil,nil,file);*/
    //[NSWorkspace openFile:[[configSelector selectedItem] title]];
}

- (IBAction)selectFont:(id)sender {
    
}

- (IBAction)openGhostDir:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: [ghostController ghostDir]]];
}

- (IBAction)openConfigDir:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: [ghostController configDir]]];
}

// handle enter event from command input
- (BOOL)control: (NSControl *)control textView:(NSTextView *)textView doCommandBySelector: (SEL)commandSelector {
	//NSLog(@"entered control area = %@",NSStringFromSelector(commandSelector));
	if (commandSelector == @selector(insertNewline:)) {
		// pressed key was enter
		
	}
	return YES;
}
@end
