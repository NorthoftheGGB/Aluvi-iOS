//
//  VCLocation.m
//  Voco
//
//  Created by Matthew Shultz on 6/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCGeoObject.h"

@implementation VCGeoObject

+ (void)createMappings:(RKObjectManager *)objectManager {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCGeoObject class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"latitude" : @"latitude",
                                                  @"longitude" : @"longitude"
                                                  }];
    RKObjectMapping * requestMapping = [mapping inverseMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCGeoObject class] rootKeyPath:nil method:RKRequestMethodPUT];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[self class] pathPattern:API_GEO_DRIVER_PATH method:RKRequestMethodGET]];
    [objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[self class] pathPattern:API_GEO_DRIVER_PATH method:RKRequestMethodPUT]];
    
    {
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                             method:RKRequestMethodPUT
                                                                                        pathPattern:API_GEO_DRIVER_PATH
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
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
