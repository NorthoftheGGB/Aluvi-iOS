//
//  Earning.h
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Earning : NSManagedObject

@property (nonatomic, retain) NSNumber * amountCents;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * ticket_id;
@property (nonatomic, retain) NSString * motive;

+ (void)createMappings:(RKObjectManager *)objectManager;

@end
