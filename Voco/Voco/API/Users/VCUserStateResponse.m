//
//  VCUserStateResponse.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCUserStateResponse.h"

@implementation VCUserStateResponse
+ (RKObjectMapping *)getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCUserStateResponse class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"driver_state" : @"driverState",
                                                  @"rider_state" : @"riderState"
                                                  }];
    return mapping;
    
}


@end
