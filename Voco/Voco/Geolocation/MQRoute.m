//
//  MQRoute.m
//  Voco
//
//  Created by Matthew Shultz on 6/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "MQRoute.h"

@implementation MQRoute

+ (RKObjectMapping *) getMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[MQRoute class]];
    
    RKObjectMapping * shapeMapping = [MQShape getMapping];
    RKObjectMapping * boundingBoxMapping = [MQBoundingBox getMapping];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shape" toKeyPath:@"shape" withMapping:shapeMapping]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"boundingBox" toKeyPath:@"boundingBox" withMapping:boundingBoxMapping]];

    return mapping;
}

@end
