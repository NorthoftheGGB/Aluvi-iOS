//
//  Car.m
//  Voco
//
//  Created by Matthew Shultz on 6/25/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Car.h"
#import "Ticket.h"


@implementation Car

@dynamic make;
@dynamic model;
@dynamic licensePlate;
@dynamic state;
@dynamic year;
@dynamic id;
@dynamic tickets;
@dynamic carPhotoUrl;

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Car" inManagedObjectStore:[VCCoreData managedObjectStore]];
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"id",
                                                        @"make": @"make",
                                                        @"model" :@"model",
                                                        @"license_plate" : @"licensePlate",
                                                        @"state" : @"state",
                                                        @"year" : @"year",
                                                        @"car_photo" : @"carPhotoUrl"
                                                        }];
    
    entityMapping.identificationAttributes = @[ @"id" ]; 

    return entityMapping;
}



- (NSString *) summary {
    return [NSString stringWithFormat:@"%@ %@ %@", self.year, self.make, self.model];
}

@end
