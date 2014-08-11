//
//  VCRideRequestCreated.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideRequestCreated.h"
#import "VCApi.h"

@implementation VCRideRequestCreated

+ (RKObjectMapping *) getMapping {

    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCRideRequestCreated class] ];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"ride_id": @"rideId",
                                                  @"trip_id": @"tripId"
                                                  }];
    return mapping;
}

@end
