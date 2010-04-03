//
//  FriendInfo.h
//  Genie
//
//  Created by Lucas on 02.04.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class User;

@interface FriendInfo :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * area;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) User * user;

@end



