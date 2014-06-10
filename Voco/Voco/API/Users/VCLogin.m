//
//  VCLogin.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLogin.h"

@implementation VCLogin

+ (RKObjectMapping *)getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCLogin class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"phone" : @"phone",
                                                  @"password" : @"password"
                                                  }];
    return mapping;
    
}

@end
