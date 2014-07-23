//
//  VCApiError.m
//  Voco
//
//  Created by Matthew Shultz on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCApiError.h"

@implementation VCApiError

+ (RKObjectMapping * )getMapping {

    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"error" : @"error"
                                                  }];
    return mapping;

}

@end
