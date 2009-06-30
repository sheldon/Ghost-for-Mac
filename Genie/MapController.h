//
//  MapController.h
//  Genie
//
//  Created by Lucas on 18.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"


@interface MapController : NSViewController <MBPreferencesModule> {
	NSMutableArray *mapconfigs;
	IBOutlet NSArrayController *mapconfigController;
	NSString *mapDir;
}
@property(retain) NSMutableArray *mapconfigs;
@end
