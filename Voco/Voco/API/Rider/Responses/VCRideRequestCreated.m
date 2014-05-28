//
//  VCRideRequestCreated.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideRequestCreated.h"
#import "VCApi.h"

@implementation VCRideRequestCreated

+ (void) createMappings: (RKObjectManager *) objectManager {

    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCRideRequestCreated class] ];
    [mapping addAttributeMappingsFromDictionary:@{@"request_id": @"rideRequestId"}];
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                             method:RKRequestMethodPOST
                                                                                        pathPattern:API_POST_RIDE_REQUEST keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

}

@end
