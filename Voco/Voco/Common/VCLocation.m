//
//  VCLocation.m
//  Voco
//
//  Created by Matthew Shultz on 6/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLocation.h"

@implementation VCLocation

+ (void)createMappings:(RKObjectManager *)objectManager {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCLocation class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"latitude" : @"latitude",
                                                  @"longitude" : @"longitude"
                                                  }];
    RKObjectMapping * requestMapping = [mapping inverseMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCLocation class] rootKeyPath:nil method:RKRequestMethodPUT];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                             method:RKRequestMethodPUT
                                                                                        pathPattern:API_GEO_CAR
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
}
@end
