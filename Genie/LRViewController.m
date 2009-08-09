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
@synthesize bottomOffset=_bottomOffset;

- (id<LRViewModule>)moduleForIdentifier:(NSString *)identifier
{
	for (id<LRViewModule> module in self.modules) {
		if ([[module identifier] isEqualToString:identifier]) {
			return module;
		}
	}
	return nil;
}

- (void)awakeFromNib
{
	[self setWantsLayer:YES];
	[self setAutoresizesSubviews: YES];
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
BOOL lol=NO;
- (void) setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
	if (lol)
		return;
	NSRect frame = [self frame];
	frame.origin.y -= [[self window] contentBorderThicknessForEdge:NSMinYEdge];
	//frame.size.height -= _bottomOffset;
	//frame.size.height += _bottomOffset;
	[[/*[*/_currentModule view]/* animator]*/ setFrame:frame];
	//[[[_currentModule view] animator] setFrameSize:newSize];
	//NSLog(@"new size: %fw %fh",newSize.width,  
		  //newSize.height);
}

- (void)animationDidEnd:(NSAnimation*)animation;
{
	NSLog(@"finished!");
}


-(NSRect)newFrameForNewContentView:(NSView *)view {
    NSWindow *window = [self window];
	NSRect oldFrameRect = [window frame];
	NSRect newFrameRect = [window frame];
	newFrameRect.size.height -= [view frame].size.height - [self frame].size.height;
	newFrameRect.size.width -= [view frame].size.width - [self frame].size.width;
	
    NSSize newSize = newFrameRect.size;
    NSSize oldSize = oldFrameRect.size;
    
    NSRect frame = [window frame];
    frame.size = newSize;
    frame.origin.y -= (newSize.height - oldSize.height);
    
    return frame;
}
// NOTE: One key to having the contained view resize correctly is to have its autoresizing set correctly in IB.
//Based on the new content view frame, calculate the window's new frame
-(NSRect)newFrameForNewContentView2:(NSView *)view {
    NSWindow *window = [self window];
    NSRect newFrameRect = [window frameRectForContentRect:[view frame]];
    NSRect oldFrameRect = [window frame];
    NSSize newSize = newFrameRect.size;
    NSSize oldSize = oldFrameRect.size;
    
    NSRect frame = [window frame];
    frame.size = newSize;
    frame.origin.y -= (newSize.height - oldSize.height);
    
    return frame;
}

// NOTE: One key to having the contained view resize correctly is to have its autoresizing set correctly in IB.
//Based on the new content view frame, calculate the window's new frame
-(NSRect)newFrameForNewContentView3:(NSView *)view {
    NSWindow *window = [self window];
    NSRect newFrameRect = [window frameRectForContentRect:[view frame]];
	NSRect oldFrameRect = [window frame];
	newFrameRect.size.height += _bottomOffset;
   
    NSSize newSize = newFrameRect.size;
    NSSize oldSize = oldFrameRect.size;
    
    NSRect frame = [window frame];
    frame.size = newSize;
    frame.origin.y -= (newSize.height - oldSize.height);
    
    return frame;
}

-(void)moveAllViews {
    float deltaY = -_bottomOffset;
    
    for (NSView *subview in [self subviews]) {
			NSRect frame = [subview frame];
			frame.origin.y += deltaY;
			[[subview animator] setFrame: frame];
    }
}

- (void)_changeToModule:(id<LRViewModule>)module
{
	//[[[self window] animator] setDelegate:self];
	lol=YES;
	//_currentModule = nil;
	NSView *oldView = [_currentModule view];
	NSView *newView = [module view];
	[newView setAutoresizingMask: NSViewNotSizable];
	[oldView setAutoresizingMask: NSViewNotSizable];
	//[oldView removeFromSuperview];
	//[newView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	// Resize the window
	NSRect newWindowFrame = [[self window] frameRectForContentRect:[newView frame]];
	
	newWindowFrame = [self newFrameForNewContentView3:newView];
	//[[[self window] animator] setFrame:newWindowFrame display:YES animate:YES];
	[NSAnimationContext beginGrouping];
	if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask)
	    [[NSAnimationContext currentContext] setDuration:1.0];
	//[newView setFrameOrigin:[super frame].origin];
	if (_currentModule != nil)
		[[self animator] replaceSubview:oldView with:newView];
	else
		[[self animator] addSubview:newView];
	
	
	[[[self window] animator] setFrame:newWindowFrame display:YES animate:YES];
	//[[self animator] addSubview:newView];
	[NSAnimationContext endGrouping];
	//NSRect newframe = [[self window] frameRectForContentRect:[newView frame]];
	//newframe.size.height += _bottomOffset;
	
	//[newView setFrame:newframe];
	
	[newView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	//[[self.window toolbar] setSelectedItemIdentifier:[module identifier]];
	//[self.window setTitle:[module title]];
	[switcher setSelectedSegment:[self.modules indexOfObject:module]];
	if ([(NSObject *)module respondsToSelector:@selector(willBeDisplayed)]) {
		[module willBeDisplayed];
	}
	_currentModule = module;
	//[self moveAllViews];
	//[[self animator] addSubview:[_currentModule view]];
	//[self setAutoresizesSubviews:YES];
	
	lol=NO;
	// Autosave the selection
	//[[NSUserDefaults standardUserDefaults] setObject:[module identifier] forKey:MBPreferencesSelectionAutosaveKey];
}
- (IBAction)selectModule:(id)sender
{
	[self _changeToModule:[_modules objectAtIndex:[sender selectedSegment]]];
}
- (void)init
{
	[self setAutoresizesSubviews:YES];
	_currentModule=nil;
	_bottomOffset=26;
}
@end
