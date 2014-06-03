//
//  VCRideOffer.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideOffer.h"

@implementation VCRideOffer
+ (void) createMappings: (RKObjectManager *) objectManager{
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCRideOffer class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                        @"ride_id" : @"rideId",
                                                        @"state" : @"state"
                                                        }];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_RIDE_OFFERS_PATH_PATTERN
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    
}
@end
