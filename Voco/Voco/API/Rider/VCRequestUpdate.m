//
//  VCRequestIdentify.m
//  Voco
//
//  Created by Matthew Shultz on 6/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRequestUpdate.h"

@implementation VCRequestUpdate

+  (void)createMappings:(RKObjectManager *)objectManager {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCRequestUpdate class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"request_id" : @"requestId"
                                                  }];
    RKObjectMapping * requestMapping = [mapping inverseMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCRequestUpdate class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptor];

    
}

@end
