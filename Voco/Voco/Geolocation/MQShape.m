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
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"maneuverIndexes"
                                                                            toKeyPath:@"maneuverIndexes"
                                                                          withMapping:[RKObjectMapping mappingForClass:[NSNumber class]]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shapePoints"
                                                                            toKeyPath:@"shapePoints"
                                                                          withMapping:[RKObjectMapping mappingForClass:[NSNumber class]]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"legIndexes"
                                                                            toKeyPath:@"legIndexes"
                                                                          withMapping:[RKObjectMapping mappingForClass:[NSNumber class]]]];
    return mapping;
     
}

@end
