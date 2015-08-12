//
//  VCPickupPoint.m
//  Voco
//
//  Created by matthewxi on 8/12/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCPickupPoint.h"
#import <RKCLLocationValueTransformer.h>

@implementation VCPickupPoint

+  (RKObjectMapping *) getBaseMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCPickupPoint class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"number_of_riders" : @"numberOfRiders"
                                                  }];
    return mapping;
    
    
    
    
}

+ (RKObjectMapping *) getMapping {
    
    RKObjectMapping * mapping = [VCPickupPoint getBaseMapping];
    
    {
        RKAttributeMapping *attributeMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"point" toKeyPath:@"location"];
        attributeMapping.propertyValueClass = [CLLocation class];
        attributeMapping.valueTransformer = [RKCLLocationValueTransformer locationValueTransformerWithLatitudeKey:@"latitude" longitudeKey:@"longitude"];
        [mapping addPropertyMapping:attributeMapping];
    }
    
    return mapping;
}

@end
