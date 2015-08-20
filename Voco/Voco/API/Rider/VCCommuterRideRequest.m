//
//  VCRideRequest.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuterRideRequest.h"

@implementation VCCommuterRideRequest

+ (RKObjectMapping *) getMapping {

    RKObjectMapping * rideRequestMapping = [RKObjectMapping mappingForClass:[VCCommuterRideRequest class]];
    [rideRequestMapping addAttributeMappingsFromDictionary:@{
                                                                 @"type" : @"type",
                                                                 @"departure_latitude" : @"departureLatitude",
                                                                 @"departure_longitude" : @"departureLongitude",
                                                                 @"departure_place_name" : @"departurePlaceName",
                                                                 @"destination_latitude" : @"destinationLatitude",
                                                                 @"destination_longitude" : @"destinationLongitude",
                                                                 @"destination_place_name" : @"destinationPlaceName",
                                                                 @"departure_pickup_time" : @"pickupTime",
                                                                 @"return_pickup_time" : @"returnPickupTime",
                                                                 @"driving" : @"driving",
                                                                 @"trip_id" : @"tripId"
                                                                }];
    return rideRequestMapping;

}



@end
