//
//  VCRideRequest.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideRequest.h"

@implementation VCRideRequest

+ (void) createMappings: (RKObjectManager *) objectManager {

    RKObjectMapping * rideRequestMapping = [RKObjectMapping mappingForClass:[VCRideRequest class]];
    [rideRequestMapping addAttributeMappingsFromDictionary:@{
                                                                 @"type" : @"type",
                                                                 @"departure_latitude" : @"departureLatitude",
                                                                 @"departure_longitude" : @"departureLongitude",
                                                                 @"departure_place_name" : @"departurePlaceName",
                                                                 @"destination_latitude" : @"destinationLatitude",
                                                                 @"destination_longitude" : @"destinationLongitude",
                                                                 @"destination_place_name" : @"destinationPlaceName",
                                                                 @"desired_arrival" : @"desiredArrival"
                                                                }];
    RKObjectMapping * postRideRequestMapping = [rideRequestMapping inverseMapping];
    RKRequestDescriptor *requestDescriptorPostData = [RKRequestDescriptor requestDescriptorWithMapping:postRideRequestMapping objectClass:[VCRideRequest class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptorPostData];

}

+ (VCRideRequest *) requestForRide:(Ride *)ride {
    VCRideRequest * request = [[VCRideRequest alloc] init];
    request.type = ride.requestType;
    request.departureLatitude = ride.originLatitude;
    request.departureLongitude = ride.originLongitude;
    request.departurePlaceName = ride.originPlaceName;
    request.destinationLatitude = ride.destinationLatitude;
    request.destinationLongitude = ride.destinationLongitude;
    request.destinationPlaceName = ride.destinationPlaceName;
    request.desiredArrival = ride.desiredArrival;
    return request;
}


@end
