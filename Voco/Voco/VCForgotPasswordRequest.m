//
//  VCForgotPasswordRequest.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCForgotPasswordRequest.h"

@implementation VCForgotPasswordRequest

+ (RKObjectMapping *)getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCForgotPasswordRequest class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"email" : @"email",
                                                  @"phone" : @"phone"
                                                  }];
    return mapping;
    
}


@end
