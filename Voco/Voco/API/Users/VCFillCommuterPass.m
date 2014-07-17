//
//  VCCommuterPass.m
//  Voco
//
//  Created by Matthew Shultz on 7/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCFillCommuterPass.h"

@implementation VCFillCommuterPass

+ (RKObjectMapping *) getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"amount_cents" : @"amountCents"
                                                  }];
    
    return mapping;
    
}

@end
