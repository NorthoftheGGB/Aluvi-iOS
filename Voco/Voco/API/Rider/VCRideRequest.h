//
//  VCRideRequest.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <RestKit.h>
#import "Ride.h"



@interface VCRideRequest : NSObject

@property (nonatomic) NSInteger customerId;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSNumber * departureLatitude;
@property (nonatomic, strong) NSNumber * departureLongitude;
@property (nonatomic, strong) NSString * departurePlaceName;
@property (nonatomic, strong) NSNumber * destinationLatitude;
@property (nonatomic, strong) NSNumber * destinationLongitude;
@property (nonatomic, strong) NSString * destinationPlaceName;
@property (nonatomic, strong) NSDate * desiredArrival;

+ (void) createMappings: (RKObjectManager *) objectManager;
+ (VCRideRequest *) requestForRide:(Ride *)ride;

@end
