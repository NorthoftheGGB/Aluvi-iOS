//
//  VCProfile.m
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCProfile.h"
#import "VCApi.h"

@implementation VCProfile

+ (RKObjectMapping *) getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"default_card_token" : @"defaultCardToken"
                                                  }];
    
    return mapping;
       
}

@end
