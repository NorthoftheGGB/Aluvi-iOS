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
                                                  @"region" : @"driver_request_region",
                                                  @"driverReferralCode" : @"driver_referral_code"
                                                  }];
    return mapping;
    
}


@end
