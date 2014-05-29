//
//  VCDevice.m
//  Voco
//
//  Created by Matthew Shultz on 5/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDevice.h"

@implementation VCDevice

+ (void) createMappings: (RKObjectManager *) objectManager{
    RKObjectMapping * deviceMapping = [RKObjectMapping mappingForClass:[VCDevice class]];
    [deviceMapping addAttributeMappingsFromDictionary:@{
                                                        @"push_token" : @"pushToken"
                                                        }];
    RKObjectMapping * transmitDeviceMapping = [deviceMapping inverseMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:transmitDeviceMapping objectClass:[VCDevice class] rootKeyPath:nil method:RKRequestMethodPATCH];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:deviceMapping
                                                                                             method:RKRequestMethodPATCH
                                                                                        pathPattern:[VCApi devicesObjectPathPattern]
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    
}

@end
