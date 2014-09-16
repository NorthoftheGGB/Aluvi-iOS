//
//  Rider.h
//  Voco
//
//  Created by Matthew Shultz on 8/23/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fare;

@interface Rider : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSSet *fares;

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager;

@end

@interface Rider (CoreDataGeneratedAccessors)

- (void)addFaresObject:(Fare *)value;
- (void)removeFaresObject:(Fare *)value;
- (void)addFares:(NSSet *)values;
- (void)removeFares:(NSSet *)values;

- (NSString *)fullName;

@end
