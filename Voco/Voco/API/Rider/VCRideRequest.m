//
//  VCRideRequest.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideRequest.h"

@implementation VCRideRequest

+ (RKObjectMapping *) getMapping {

    RKObjectMapping * rideRequestMapping = [RKObjectMapping mappingForClass:[VCRideRequest class]];
    [rideRequestMapping addAttributeMappingsFromDictionary:@{
                                                                 @"type" : @"type",
                                                                 @"departure_latitude" : @"departureLatitude",
                                                                 @"departure_longitude" : @"departureLongitude",
                                                                 @"departure_place_name" : @"departurePlaceName",
                                                                 @"destination_latitude" : @"destinationLatitude",
                                                                 @"destination_longitude" : @"destinationLongitude",
                                                                 @"destination_place_name" : @"destinationPlaceName",
                                                                 @"pickup_time" : @"pickupTime",
                                                                 @"driving" : @"driving",
                                                                 @"trip_id" : @"tripId"
                                                                }];
    return rideRequestMapping;

}

+ (VCRideRequest *) requestForRide:(Ride *)ride {
    VCRideRequest * rideRequest = [[VCRideRequest alloc] init];
    rideRequest.type = ride.rideType;
    rideRequest.departureLatitude = ride.originLatitude;
    rideRequest.departureLongitude = ride.originLongitude;
    rideRequest.departurePlaceName = ride.originPlaceName;
    rideRequest.destinationLatitude = ride.destinationLatitude;
    rideRequest.destinationLongitude = ride.destinationLongitude;
    rideRequest.destinationPlaceName = ride.destinationPlaceName;
    rideRequest.pickupTime = ride.pickupTime;
    rideRequest.driving = ride.driving;
    rideRequest.tripId = ride.trip_id;
    return rideRequest;
}


@end
