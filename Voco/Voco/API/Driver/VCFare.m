//
//  VCFare.m
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCFare.h"
#import "VCApi.h"

@implementation VCFare

+ (RKObjectMapping*) getMapping {
    
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id" : @"id",
                                                  @"amount" : @"amount",
                                                  @"driver_earnings" : @"driverEarnings"
                                                  }];
    return mapping;

}
@end
