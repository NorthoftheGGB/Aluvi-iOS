//
//  Rider.m
//  Voco
//
//  Created by Matthew Shultz on 8/23/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Rider.h"
#import "Fare.h"

@implementation Rider

@dynamic firstName;
@dynamic id;
@dynamic lastName;
@dynamic latitude;
@dynamic longitude;
@dynamic state;
@dynamic fares;
@dynamic phone;

+ (RKEntityMapping *) createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Rider"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"id",
                                                        @"state" : @"state",
                                                        @"first_name" : @"firstName",
                                                        @"last_name" : @"lastName",
                                                        @"phone" : @"phone",
                                                        @"latitude" : @"latitude",
                                                        @"longitude" : @"longitude"
                                                        }];
    
    
    entityMapping.identificationAttributes = @[ @"id" ];
    return entityMapping;
    
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}
@end
