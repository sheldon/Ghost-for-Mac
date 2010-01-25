/*	NSComboBoxDropTarget.m
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 20.01.10
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

#import "NSComboBoxDropTarget.h"


@implementation NSComboBoxDropTarget

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		NSArray *draggedTypeArray = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
        [self registerForDraggedTypes:draggedTypeArray];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];

    NSArray *supportedFiletypes = [NSArray arrayWithObjects:@"w3x", @"cfg", @"w3m", nil];
    int dragOperation = NSDragOperationNone;
    if ([filenames count]) {
		
        /*
		 Decide here if you accept the filenames that are dragged into the view.
		 If you do accept the dragged filenames then set dragOperation to 
		 NSDragOperationCopy:
		 
		 dragOperation = NSDragOperationCopy;
		 
		 Here is where you can give some user feedback if the filenames
		 are valid files (e.g. change a boarder color or the background color of the view)
		 
		 */
        
        NSEnumerator *filenameEnum = [filenames objectEnumerator]; 
        NSString *filename;
        dragOperation = NSDragOperationCopy;
        while (filename = [filenameEnum nextObject]) {
            if (![supportedFiletypes containsObject:[filename pathExtension]]) {
                dragOperation = NSDragOperationNone;
                break;
            }
        }
        //if (dragOperation == NSDragOperationCopy) backgroundColor = greenColor;
    }       
    [self setNeedsDisplay:YES];
    return dragOperation;
}

-(void)draggingExited:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
    BOOL didPerformDragOperation = NO;

    if ([filenames count]) {
        
        /*
		 
		 Do something here with filenames and 
		 decide if a dragging operation was actually performed.
		 If an operation was performed set didPerformDragOperation
		 to YES:
		 
		 didPerformDragOperation = YES;
		 
		 */
		
    }
    return didPerformDragOperation;
}

-(void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    
    /*
	 This method gives you the chance to change any state variables that
	 deal with dragAndDrop.
	 
	 */
	
    NSLog(@"concludeDragOperation:");
}

@end
