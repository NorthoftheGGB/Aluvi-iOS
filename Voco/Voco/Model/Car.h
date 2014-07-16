//
//  Car.h
//  Voco
//
//  Created by Matthew Shultz on 6/25/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Request;

@interface Car : NSManagedObject

@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * licensePlate;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *rides;

@end

@interface Car (CoreDataGeneratedAccessors)

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager;


- (void)addRidesObject:(Request *)value;
- (void)removeRidesObject:(Request *)value;
- (void)addRides:(NSSet *)values;
- (void)removeRides:(NSSet *)values;

- (NSString *) summary;

@end
