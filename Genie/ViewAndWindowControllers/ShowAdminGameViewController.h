/*	ShowAdminGameViewController.h
 *
 *	This file is part of Genie
 *	Copyright (C) 2009-2010 Lucas Romero
 *	Created 08.02.10
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

#import <Cocoa/Cocoa.h>


#import "BotViewControllerInterface.h"

@class BotAdminGame;

@interface ShowAdminGameViewController : NSViewController <BotViewControllerInterface> {
	BotAdminGame *selectedBot;
	IBOutlet NSArrayController *messageController;
	IBOutlet NSArrayController *serverController;
	IBOutlet NSTableView *messageTable;
	IBOutlet NSTabView *tabView;
}
- (IBAction)execCommand:(id)sender;
- (IBAction)copyLines:(id)sender;

@property (nonatomic, retain) BotAdminGame *selectedBot;
@end
