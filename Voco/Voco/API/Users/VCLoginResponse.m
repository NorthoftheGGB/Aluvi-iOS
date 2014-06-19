//
//  VCTokenResponse.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLoginResponse.h"

@implementation VCLoginResponse
+ (RKObjectMapping *)getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCLoginResponse class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"token" : @"token",
                                                  @"driver_state" : @"driverState",
                                                  @"rider_state" : @"riderState"
                                                  }];
    return mapping;
    
}


@end
