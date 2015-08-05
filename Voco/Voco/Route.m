//
//  Route.m
//  Voco
//
//  Created by Matthew Shultz on 10/26/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Route.h"
#import <RKCLLocationValueTransformer.h>


@implementation Route


+ (RKObjectMapping *) getBaseMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"origin_place_name" : @"homePlaceName",
                                                  @"destination_place_name" : @"workPlaceName",
                                                  @"pickup_time" : @"pickupTime",
                                                  @"return_time" : @"returnTime",
                                                  @"driving" : @"driving"
                                                  }];
    
    return mapping;
}

+ (RKObjectMapping *) getMapping {
    
    RKObjectMapping * mapping = [Route getBaseMapping];
    
    {
        RKAttributeMapping *attributeMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"origin" toKeyPath:@"home"];
        attributeMapping.propertyValueClass = [CLLocation class];
        attributeMapping.valueTransformer = [RKCLLocationValueTransformer locationValueTransformerWithLatitudeKey:@"latitude" longitudeKey:@"longitude"];
        [mapping addPropertyMapping:attributeMapping];
    }
    
    {
        RKAttributeMapping *attributeMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"destination" toKeyPath:@"work"];
        attributeMapping.propertyValueClass = [CLLocation class];
        attributeMapping.valueTransformer = [RKCLLocationValueTransformer locationValueTransformerWithLatitudeKey:@"latitude" longitudeKey:@"longitude"];
        [mapping addPropertyMapping:attributeMapping];
    }
    
    return mapping;
    
}

+ (RKObjectMapping *) getInverseMapping {
    RKObjectMapping * mapping = [[Route getBaseMapping] inverseMapping];
    
    {
        RKAttributeMapping *attributeMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"home" toKeyPath:@"origin"];
        attributeMapping.propertyValueClass = [NSDictionary class];
        attributeMapping.valueTransformer = [RKCLLocationValueTransformer locationValueTransformerWithLatitudeKey:@"latitude" longitudeKey:@"longitude"];
        [mapping addPropertyMapping:attributeMapping];
    }
    
    {
        RKAttributeMapping *attributeMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"work" toKeyPath:@"destination"];
        attributeMapping.propertyValueClass = [NSDictionary class];
        attributeMapping.valueTransformer = [RKCLLocationValueTransformer locationValueTransformerWithLatitudeKey:@"latitude" longitudeKey:@"longitude"];
        [mapping addPropertyMapping:attributeMapping];
    }
    
    return mapping;
    
}

- (id)copyWithZone:(NSZone *)zone
{
    Route * copy = [[Route alloc] init];
    if(copy){
        copy.home = self.home;
        copy.work = self.work;
        copy.homePlaceName = [self.homePlaceName copy];
        copy.workPlaceName = [self.workPlaceName copy];
        copy.driving = self.driving;
        copy.pickupTime = [self.pickupTime copy];
        copy.returnTime = [self.returnTime copy];
        copy.polyline = [self.polyline copy];
        copy.region = [self.region copy];
    }
    return copy;
}


- (BOOL) routeSettingsValid {
    if( self.home == nil || self.work == nil || self.pickupTime == nil || self.returnTime == nil){
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) hasCachedRoute {
    if(self.polyline != nil && self.region != nil && [self.polyline count] > 0){
        return TRUE;
    } else {
        return FALSE;
    }
}

@end
