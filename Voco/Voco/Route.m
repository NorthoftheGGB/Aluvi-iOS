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
                                                  @"driving" : @"driving",
                                                  @"pickup_zone_center_place_name" : @"pickupZoneCenterPlaceName"
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
    
    {
        RKAttributeMapping *attributeMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"pickup_zone_center" toKeyPath:@"pickupZoneCenter"];
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
    
    {
        RKAttributeMapping *attributeMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"pickupZoneCenter" toKeyPath:@"pickup_zone_center"];
        attributeMapping.propertyValueClass = [NSDictionary class];
        attributeMapping.valueTransformer = [RKCLLocationValueTransformer locationValueTransformerWithLatitudeKey:@"latitude" longitudeKey:@"longitude"];
        [mapping addPropertyMapping:attributeMapping];
    }
    
    return mapping;
    
}

- (id) init {
    self = [super init];
    if(self != nil){
        [self observeCoordinates];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Route * copy = [[Route alloc] init];
    if(copy){
        copy.home = self.home;
        copy.work = self.work;
        copy.homePlaceName = [self.homePlaceName copy];
        copy.workPlaceName = [self.workPlaceName copy];
        copy.pickupZoneCenter = self.pickupZoneCenter;
        copy.pickupZoneCenterPlaceName = self.pickupZoneCenterPlaceName;
        copy.driving = self.driving;
        copy.pickupTime = [self.pickupTime copy];
        copy.returnTime = [self.returnTime copy];
        copy.polyline = [self.polyline copy];
        copy.region = [self.region copy];
    }
    return copy;
}

- (BOOL) routeCoordinateSettingsValid {

    if(_driving){
        return [self zoneToWorkCoordinatesValid];
    } else {
        return [self pickupToWorkCoordinatesValid];
    }
}


- (BOOL) pickupToWorkCoordinatesValid {
    if( self.home == nil || self.work == nil){
        return NO;
    } else if( [self coordinatesOutOfRange: self.home]
              || [self coordinatesOutOfRange: self.work]
              ) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) zoneToWorkCoordinatesValid {
    if( self.pickupZoneCenter == nil || self.work == nil){
        return NO;
    } else if( [self coordinatesOutOfRange: self.pickupZoneCenter]
              || [self coordinatesOutOfRange: self.work]
              ) {
        return NO;
    } else {
        return YES;
    }
}

              
- (BOOL) coordinatesOutOfRange: (CLLocation *) location {
    if( location.coordinate.latitude < 23 && location.coordinate.latitude > 50 ){
        return YES;
    }
    if( location.coordinate.longitude < -130 && location.coordinate.longitude < -60 ){
        return YES;
    }
    return NO;
}

- (BOOL) hasCachedPath {
    if(self.polyline != nil && self.region != nil && [self.polyline count] > 0 && [self.region isValidRegion] ) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void) clearCachedPath {
    self.polyline = nil;
    self.region = nil;
    
}

- (BOOL) coordinatesDifferFrom: (Route*) route {
    if( [self.home distanceFromLocation:route.home] != 0
       || [self.work distanceFromLocation:route.work] != 0
       || [self.pickupZoneCenter distanceFromLocation:route.pickupZoneCenter]){
        return TRUE;
    } else{
        return FALSE;
    }
}

- (void) copyNonCoordinateFieldsFrom: (Route*) route {
    self.pickupTime = route.pickupTime;
    self.returnTime = route.returnTime;
    self.homePlaceName = route.homePlaceName;
    self.workPlaceName = route.workPlaceName;
    self.pickupZoneCenterPlaceName = route.pickupZoneCenterPlaceName;
    self.driving = route.driving;
}

- (CLLocation *) getDefaultOrigin {
    if(_driving){
        return _pickupZoneCenter;
    } else {
        return _home;
    }
}



#pragma mark Observing
- (void)observeCoordinates {
    [self addObserver:self forKeyPath:@"home"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
    [self addObserver:self forKeyPath:@"work"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"home"] || [keyPath isEqualToString:@"work"] ) {
        CLLocation *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        CLLocation *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if([oldValue isEqual:[NSNull null]]|| [newValue isEqual:[NSNull null]]){
            [self clearCachedPath];
        } else if (![newValue distanceFromLocation:oldValue] != 0 ) {
            [self clearCachedPath];
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"home"];
    [self removeObserver:self forKeyPath:@"work"];

}



@end
