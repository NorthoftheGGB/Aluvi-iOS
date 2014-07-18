//
//  Driver.m
//  Voco
//
//  Created by Matthew Shultz on 6/25/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Driver.h"
#import "Ride.h"


@implementation Driver

@dynamic firstName;
@dynamic lastName;
@dynamic id;
@dynamic driversLicenseNumber;
@dynamic phone;
@dynamic rides;

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Driver" inManagedObjectStore:[VCCoreData managedObjectStore]];
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"first_name": @"firstName",
                                                        @"last_name" :@"lastName",
                                                        @"id" : @"id",
                                                        @"drivers_license_number" : @"driversLicenseNumber",
                                                        @"phone" : @"phone"
                                                       }];
    return entityMapping;
}


- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}


@end
