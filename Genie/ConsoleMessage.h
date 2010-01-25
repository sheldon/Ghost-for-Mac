//
//  ConsoleMessage.h
//  Genie
//
//  Created by Lucas on 11.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Message.h"

@class Bot;

@interface ConsoleMessage :  Message  
{
}

@property (nonatomic, retain) Bot * bot;

@end



