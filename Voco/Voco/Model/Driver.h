//
//  Driver.h
//  Voco
//
//  Created by Matthew Shultz on 6/25/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ride;

@interface Driver : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * driversLicenseNumber;
@property (nonatomic, retain) NSString * driversLicenseUrl;
@property (nonatomic, retain) NSSet *rides;

@property (nonatomic, readonly) NSString * fullName;
@end

@interface Driver (CoreDataGeneratedAccessors)

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager;

- (void)addRidesObject:(Ride *)value;
- (void)removeRidesObject:(Ride *)value;
- (void)addRides:(NSSet *)values;
- (void)removeRides:(NSSet *)values;

@end
