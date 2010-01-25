//
//  GMap.h
//  Genie
//
//  Created by Lucas on 21.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BotLocal;
@class GMapFile;

@interface GMap :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * hcl;
@property (nonatomic, retain) NSNumber * loadIngame;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * clientPath;
@property (nonatomic, retain) NSString * statsModule;
@property (nonatomic, retain) GMapFile * mapfile;
@property (nonatomic, retain) NSSet* bots;
@property (nonatomic, retain) NSSet* settings;
@property (nonatomic, retain, readonly) NSArray* clientPathSuggestions;

@end


@interface GMap (CoreDataGeneratedAccessors)
- (void)addBotsObject:(BotLocal *)value;
- (void)removeBotsObject:(BotLocal *)value;
- (void)addBots:(NSSet *)value;
- (void)removeBots:(NSSet *)value;

- (void)addSettingsObject:(NSManagedObject *)value;
- (void)removeSettingsObject:(NSManagedObject *)value;
- (void)addSettings:(NSSet *)value;
- (void)removeSettings:(NSSet *)value;

@end

