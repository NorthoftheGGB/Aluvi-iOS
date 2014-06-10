//
//  VCNewUser.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCNewUser.h"

@implementation VCNewUser

+ (RKObjectMapping *)getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCNewUser class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"name" : @"name",
                                                  @"email" : @"email",
                                                  @"password" : @"password",
                                                  @"phone" : @"phone",
                                                  @"referral_code" : @"referralCode"
                                                  }];
    return mapping;
    
}

@end
