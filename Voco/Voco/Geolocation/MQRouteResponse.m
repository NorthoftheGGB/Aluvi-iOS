//
//  VCMapQuestRouteResponse.m
//  Voco
//
//  Created by Matthew Shultz on 6/12/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "MQRouteResponse.h"

@implementation MQRouteResponse

+ (RKObjectMapping *) getMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[MQRouteResponse class]];
    
    RKObjectMapping * shapeMapping = [MQShape getMapping];
    [mapping addRelationshipMappingWithSourceKeyPath:@"shape" mapping:shapeMapping];
    
    return mapping;
}


@end
