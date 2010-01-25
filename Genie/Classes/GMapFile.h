//
//  GMapFile.h
//  Genie
//
//  Created by Lucas on 21.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class GMap;

@interface GMapFile :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSSet* maps;
@property (nonatomic, readonly) NSString * name;

@end


@interface GMapFile (CoreDataGeneratedAccessors)
- (void)addMapsObject:(GMap *)value;
- (void)removeMapsObject:(GMap *)value;
- (void)addMaps:(NSSet *)value;
- (void)removeMaps:(NSSet *)value;

@end

