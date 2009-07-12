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

#import "LRViewController.h"

@interface LRViewController (Private)
- (void)_selectModule:(NSToolbarItem *)sender;
- (void)_changeToModule:(id<LRViewModule>)module;
@end

@implementation LRViewController
@synthesize modules=_modules;

- (id<LRViewModule>)moduleForIdentifier:(NSString *)identifier
{
	for (id<LRViewModule> module in self.modules) {
		if ([[module identifier] isEqualToString:identifier]) {
			return module;
		}
	}
	return nil;
}

/*- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
	NSLog(@"SubviewsWithOldSize: %fw %fh",oldBoundsSize.width,  
		  oldBoundsSize.height);
}*/

- (void)setModules:(NSArray *)newModules
{
	if (_modules) {
		[_modules release];
		_modules = nil;
	}
	
	if (newModules != _modules) {
		_modules = [newModules retain];
		
		if (switcher) {
			//clear switcher
			[switcher setSegmentCount:0];
			
			// Add the new items
			for (id<LRViewModule> module in self.modules) {
				//[toolbar insertItemWithItemIdentifier:[module identifier] atIndex:[[toolbar items] count]];
				[switcher setSegmentCount:[switcher segmentCount]+1];
				[switcher setLabel:[module title] forSegment:[switcher segmentCount]-1];
				[switcher setImage:[module image] forSegment:[switcher segmentCount]-1];
			}
		}
		
		// Change to the correct module
		if ([self.modules count]) {
			id<LRViewModule> defaultModule = nil;
			
			// Check the autosave info
			//NSString *savedIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:MBPreferencesSelectionAutosaveKey];
			//defaultModule = [self moduleForIdentifier:savedIdentifier];
			
			if (!defaultModule) {
				defaultModule = [self.modules objectAtIndex:0];
			}
			
			[self _changeToModule:defaultModule];
		}
		
	}
}

- (void)_selectModule:(NSToolbarItem *)sender
{
	/*if (![sender isKindOfClass:[NSToolbarItem class]])
		return;
	
	id<LRViewModule> module = [self moduleForIdentifier:[sender itemIdentifier]];
	if (!module)
		return;
	
	[self _changeToModule:module];*/
}

- (void) setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
	[[_currentModule view] setFrameSize:newSize];
	//NSLog(@"new size: %fw %fh",newSize.width,  
		  //newSize.height);
}

- (void)_changeToModule:(id<LRViewModule>)module
{
	[[_currentModule view] removeFromSuperview];
	
	NSView *newView = [module view];
	//[self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
	//[newView setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
	// Resize the window
	NSRect newWindowFrame = [[self window] frameRectForContentRect:[newView frame]];
	NSRect oldWindow = [[self window] frame];
	newWindowFrame = oldWindow;
	newWindowFrame.origin = oldWindow.origin;
	newWindowFrame.size.height += [newView frame].size.height - [self frame].size.height;
	newWindowFrame.size.width += [newView frame].size.width - [self frame].size.width;
	
	//newWindowFrame.origin.y -= newWindowFrame.size.height - [self frame].size.height;
	[[self window] setFrame:newWindowFrame display:YES animate:YES];
	
	//[[self.window toolbar] setSelectedItemIdentifier:[module identifier]];
	//[self.window setTitle:[module title]];
	[switcher setSelectedSegment:[self.modules indexOfObject:module]];
	if ([(NSObject *)module respondsToSelector:@selector(willBeDisplayed)]) {
		[module willBeDisplayed];
	}
	
	_currentModule = module;
	[self addSubview:[_currentModule view]];
	[self setAutoresizesSubviews:YES];
	[[_currentModule view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	// Autosave the selection
	//[[NSUserDefaults standardUserDefaults] setObject:[module identifier] forKey:MBPreferencesSelectionAutosaveKey];
}
@end
