//
//  VCDriverGeoObject.m
//  Voco
//
//  Created by Matthew Shultz on 7/15/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverGeoObject.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>#import "VCApi.h"

@implementation VCDriverGeoObject
+ (RKObjectMapping*)getMapping {

    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"latitude" : @"latitude",
                                                  @"longitude" : @"longitude",
                                                  @"current_fare_cost" : @"currentFareCost",
                                                  @"current_fare_id" : @"currentFareId"
                                                  }];
    
    return mapping;
    
}
@end
