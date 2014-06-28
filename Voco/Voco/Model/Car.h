//
//  Car.h
//  Voco
//
//  Created by Matthew Shultz on 6/25/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ride;

@interface Car : NSManagedObject

@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * licensePlate;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *rides;

@property (nonatomic, readonly) NSString * description;
@end

@interface Car (CoreDataGeneratedAccessors)

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager;


- (void)addRidesObject:(Ride *)value;
- (void)removeRidesObject:(Ride *)value;
- (void)addRides:(NSSet *)values;
- (void)removeRides:(NSSet *)values;

@end