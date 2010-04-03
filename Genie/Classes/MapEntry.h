//
//  MapEntry.h
//  Genie
//
//  Created by Lucas on 03.04.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class GMap;

@interface MapEntry :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) GMap * map;

@end



