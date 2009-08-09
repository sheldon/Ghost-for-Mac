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

#import <Cocoa/Cocoa.h>


@protocol LRViewModule

@required
- (NSString *)title;
- (NSString *)identifier;
- (NSImage *)image;
- (NSView *)view;
@optional
- (void)willBeDisplayed;
@end



@interface LRViewController : NSView {
	IBOutlet NSSegmentedControl* switcher;
	NSArray *_modules;
	int _bottomOffset;
	id<LRViewModule> _currentModule;
}

@property(retain) NSArray *modules;
@property int bottomOffset;
- (id<LRViewModule>)moduleForIdentifier:(NSString *)identifier;
- (IBAction)selectModule:(id)sender;
@end
