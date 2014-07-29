//
//  VCRequestIdentify.m
//  Voco
//
//  Created by Matthew Shultz on 6/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRequestUpdate.h"

@implementation VCRequestUpdate

+  (RKObjectMapping *) getMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCRequestUpdate class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"request_id" : @"requestId"
                                                  }];
    return mapping;



    
}

@end
