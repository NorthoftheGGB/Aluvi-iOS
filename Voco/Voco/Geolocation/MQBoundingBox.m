//
//  MQBoundingBox.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "MQBoundingBox.h"

@implementation MQBoundingBox

+ (RKObjectMapping *)getMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ul" toKeyPath:@"ul" withMapping:[MQCoordinate getMapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"lr" toKeyPath:@"lr" withMapping:[MQCoordinate getMapping]]];
    return mapping;
}

@end

@implementation MQCoordinate

+ (RKObjectMapping *)getMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[MQCoordinate class]];
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"lng" toKeyPath:@"lng"]];
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"lat" toKeyPath:@"lat"]];
    return mapping;
}
@end