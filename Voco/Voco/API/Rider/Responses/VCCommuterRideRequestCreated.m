//
//  VCRideRequestCreated.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuterRideRequestCreated.h"
#import "VCApi.h"

@implementation VCCommuterRideRequestCreated

+ (RKObjectMapping *) getMapping {

    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCCommuterRideRequestCreated class] ];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"trip_id": @"tripId",
                                                  @"outgoing_ride_id": @"outgoingRideId",
                                                  @"return_ride_id": @"returnRideId"
                                                  }];
    return mapping;
}

@end
