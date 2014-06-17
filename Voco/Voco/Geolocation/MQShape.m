//
//  MQShape.m
//  Voco
//
//  Created by Matthew Shultz on 6/12/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "MQShape.h"

@implementation MQShape

+ (RKObjectMapping *) getMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[MQShape class]];
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"shapePoints" toKeyPath:@"shapePoints"]];
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"maneuverIndexes" toKeyPath:@"maneuverIndexes"]];
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"legIndexes" toKeyPath:@"legIndexes"]];
    return mapping;
}

@end
