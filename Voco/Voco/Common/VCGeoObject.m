//
//  VCLocation.m
//  Voco
//
//  Created by Matthew Shultz on 6/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCGeoObject.h"

@implementation VCGeoObject

+ (RKObjectMapping*) getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCGeoObject class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"latitude" : @"latitude",
                                                  @"longitude" : @"longitude"
                                                  }];
    return  mapping;
    
    
    
    
}
@end
