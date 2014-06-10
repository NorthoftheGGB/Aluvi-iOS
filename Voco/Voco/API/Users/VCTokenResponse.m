//
//  VCTokenResponse.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTokenResponse.h"

@implementation VCTokenResponse
+ (RKObjectMapping *)getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCTokenResponse class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"token" : @"token"
                                                  }];
    return mapping;
    
}


@end
