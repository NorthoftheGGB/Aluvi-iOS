//
//  VCDriverGeoObject.m
//  Voco
//
//  Created by Matthew Shultz on 7/15/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverGeoObject.h"
#import <RestKit.h>
#import "VCApi.h"

@implementation VCDriverGeoObject
+ (void)createMappings:(RKObjectManager *)objectManager {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"latitude" : @"latitude",
                                                  @"longitude" : @"longitude",
                                                  @"current_fare_cost" : @"currentFareCost",
                                                  @"current_fare_id" : @"currentFareId"
                                                  }];
    

    {
        RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:API_GEO_DRIVER_PATH
                                                                                                 keyPath:nil
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor2];
    }
    
    
}
@end
