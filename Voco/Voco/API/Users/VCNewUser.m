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
                                                  @"first_name" : @"firstName",
                                                  @"last_name" : @"lastName",
                                                  @"email" : @"email",
                                                  @"password" : @"password",
                                                  @"phone" : @"phone",
                                                  @"referral_code" : @"referralCode",
                                                  @"driver" : @"driver"
                                                  }];
    return mapping;
    
}

@end
