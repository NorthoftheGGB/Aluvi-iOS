//
//  Driver.m
//  Voco
//
//  Created by Matthew Shultz on 6/25/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Driver.h"
#import "Ticket.h"


@implementation Driver

@dynamic firstName;
@dynamic lastName;
@dynamic id;
@dynamic driversLicenseNumber;
@dynamic phone;
@dynamic smallImageUrl;
@dynamic largeImageUrl;
@dynamic tickets;

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Driver" inManagedObjectStore:[VCCoreData managedObjectStore]];
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"id",
                                                        @"first_name": @"firstName",
                                                        @"last_name" :@"lastName",
                                                        @"drivers_license_number" : @"driversLicenseNumber",
                                                        @"phone" : @"phone",
                                                        @"large_image" : @"largeImageUrl",
                                                        @"small_image" : @"smallImageUrl"
                                                       }];
    entityMapping.identificationAttributes = @[ @"id" ];

    return entityMapping;
}


- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}


@end
