//
//  VCRideDriverAssignment.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCFareDriverAssignment.h"

@implementation VCFareDriverAssignment

+ (RKObjectMapping*) getMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCFareDriverAssignment class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"fare_id" : @"fareId"
                                                  }];
    return mapping;
    
   
}

@end
