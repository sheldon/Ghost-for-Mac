//
//  GHostMapConfig.h
//  Genie
//
//  Created by Lucas on 30.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GHostMapConfig : NSObject {
	NSString *fullPath;
	NSString *name;
//	NSString *content;
}
- (id)initWithFile:(NSString*)path;
//@property(copy) NSString *content;
@property(copy) NSString *name;
@end
