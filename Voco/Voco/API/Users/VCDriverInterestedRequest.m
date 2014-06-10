//
//  VCDriverInterestedRequest.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverInterestedRequest.h"

@implementation VCDriverInterestedRequest

+ (RKObjectMapping *)getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCDriverInterestedRequest class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"name" : @"name",
                                                  @"email" : @"email",
                                                  @"phone" : @"phone",
                                                  @"driver_request_region" : @"region",
                                                  @"driver_referral_code" : @"driverReferralCode"
                                                  }];
    return mapping;
    
}


@end
