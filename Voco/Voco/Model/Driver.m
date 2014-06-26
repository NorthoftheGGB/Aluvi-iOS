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
@dynamic driversLicenseUrl;
@dynamic rides;
@synthesize fullName;

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Driver" inManagedObjectStore:objectManager.managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"first_name": @"firstName",
                                                        @"last_name" :@"lastName",
                                                        @"id" : @"id",
                                                        @"drivers_license_number" : @"driversLicenseNumber",
                                                        @"drivers_license_url" : @"driversLicenseUrl"
                                                       }];
    return entityMapping;
}


- (NSString *)getFullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}


@end
