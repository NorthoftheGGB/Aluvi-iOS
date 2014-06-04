//
//  VCRideIdentity.m
//  Voco
//
//  Created by Matthew Shultz on 6/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideIdentity.h"

@implementation VCRideIdentity

+ (void)createMappings:(RKObjectManager *)objectManager {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCRideIdentity class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                    @"rider_id" : @"riderId",
                                                    @"ride_id" : @"rideId"
                                                }];
    RKObjectMapping * requestMapping = [mapping inverseMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCRideIdentity class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                             method:RKRequestMethodPOST
                                                                                        pathPattern:API_POST_RIDER_CANCELLED
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    // These are part of the driver API
    RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                             method:RKRequestMethodPOST
                                                                                        pathPattern:API_POST_RIDE_PICKUP
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor2];
    RKResponseDescriptor * responseDescriptor3 = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                              method:RKRequestMethodPOST
                                                                                         pathPattern:API_POST_RIDE_ARRIVED
                                                                                             keyPath:nil
                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor3];
    
}

@end
