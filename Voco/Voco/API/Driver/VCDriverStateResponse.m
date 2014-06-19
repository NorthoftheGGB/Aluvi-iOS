//
//  VCDriveStateResponse.m
//  Voco
//
//  Created by Matthew Shultz on 6/19/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverStateResponse.h"

@implementation VCDriverStateResponse

+ (RKObjectMapping *)getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"driver_state" : @"state"
                                                  }];
    return mapping;
    
}


@end
