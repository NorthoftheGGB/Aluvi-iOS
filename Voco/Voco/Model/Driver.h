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

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * driversLicenseNumber;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * smallImageUrl;
@property (nonatomic, retain) NSString * largeImageUrl;
@property (nonatomic, retain) NSSet *tickets;
@end

@interface Driver (CoreDataGeneratedAccessors)

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager;

- (void)addTicketsObject:(Fare *)value;
- (void)removeTicketsObject:(Fare *)value;
- (void)addTickets:(NSSet *)values;
- (void)removeTickets:(NSSet *)values;

- (NSString *)fullName;

@end
