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
    
    RKObjectMapping * routeMapping = [MQRoute getMapping];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"route" toKeyPath:@"route" withMapping:routeMapping]];
    
    return mapping;
}


@end
