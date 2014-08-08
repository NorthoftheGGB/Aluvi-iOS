//
//  VCDevice.m
//  Voco
//
//  Created by Matthew Shultz on 5/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDevice.h"

@implementation VCDevice

+ (RKObjectMapping*) getMapping {
    RKObjectMapping * deviceMapping = [RKObjectMapping mappingForClass:[VCDevice class]];
    [deviceMapping addAttributeMappingsFromDictionary:@{
                                                        @"user_id" : @"userId",
                                                        @"push_token" : @"pushToken"
                                                        }];
    return deviceMapping;

    
}

@end
