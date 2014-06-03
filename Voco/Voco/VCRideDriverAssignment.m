//
//  VCRideDriverAssignment.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideDriverAssignment.h"

@implementation VCRideDriverAssignment

+ (void) createMappings: (RKObjectManager *) objectManager{
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCRideDriverAssignment class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"ride_id" : @"rideId",
                                                  @"driver_id" : @"driverId"
                                                  }];
    RKObjectMapping * requestMapping = [mapping inverseMapping];
    RKRequestDescriptor *requestDescriptorPostData = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCRideDriverAssignment class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptorPostData];
    
    
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                             method:RKRequestMethodPOST
                                                                                        pathPattern:API_POST_RIDE_DECLINED
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                             method:RKRequestMethodPOST
                                                                                        pathPattern:API_POST_RIDE_ACCEPTED
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor2];
    
    
}

@end
