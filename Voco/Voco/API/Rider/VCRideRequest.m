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

+ (VCRideRequest *) requestForRide:(Request *)request {
    VCRideRequest * rideRequest = [[VCRideRequest alloc] init];
    rideRequest.type = request.requestType;
    rideRequest.departureLatitude = request.originLatitude;
    rideRequest.departureLongitude = request.originLongitude;
    rideRequest.departurePlaceName = request.originPlaceName;
    rideRequest.destinationLatitude = request.destinationLatitude;
    rideRequest.destinationLongitude = request.destinationLongitude;
    rideRequest.destinationPlaceName = request.destinationPlaceName;
    rideRequest.desiredArrival = request.desiredArrival;
    return rideRequest;
}


@end
