//
//  Car.m
//  Voco
//
//  Created by Matthew Shultz on 6/25/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Car.h"
#import "Ride.h"


@implementation Car

@dynamic make;
@dynamic model;
@dynamic licensePlate;
@dynamic state;
@dynamic year;
@dynamic id;
@dynamic rides;
@synthesize description;


+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Driver" inManagedObjectStore:objectManager.managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:@{@"make": @"make",
                                                        @"model" :@"model",
                                                        @"license_plate" : @"licensePlate",
                                                        @"state" : @"state",
                                                        @"year" : @"year",
                                                        @"id" : @"id"
                                                        }];
    return entityMapping;
}

- (NSString *) getDescription {
    return [NSString stringWithFormat:@"%@ %@ %@", self.year, self.make, self.model];
}

@end
