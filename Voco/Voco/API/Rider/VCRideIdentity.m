//
//  VCRideIdentity.m
//  Voco
//
//  Created by Matthew Shultz on 6/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideIdentity.h"

@implementation VCRideIdentity

+ (RKObjectMapping *) getMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCRideIdentity class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                    @"ride_id" : @"ticketId"
                                                }];
    return mapping;
}

@end
