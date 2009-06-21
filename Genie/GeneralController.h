//
//  GeneralController.h
//  Genie
//
//  Created by Lucas on 19.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"

@interface GeneralController : NSViewController <MBPreferencesModule>{

}
- (IBAction)openGhostDir:(id)sender;
- (IBAction)openConfigDir:(id)sender;
- (IBAction)clearAppSupport:(id)sender;
@end
