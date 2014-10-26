//
//  Driver.h
//  Voco
//
//  Created by Matthew Shultz on 6/25/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fare;

@interface Driver : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * driversLicenseNumber;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * smallImageUrl;
@property (nonatomic, retain) NSString * largeImageUrl;
@property (nonatomic, retain) NSSet *rides;
@end

@interface Driver (CoreDataGeneratedAccessors)

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager;

- (void)addRidesObject:(Fare *)value;
- (void)removeRidesObject:(Fare *)value;
- (void)addRides:(NSSet *)values;
- (void)removeRides:(NSSet *)values;

- (NSString *)fullName;

@end
