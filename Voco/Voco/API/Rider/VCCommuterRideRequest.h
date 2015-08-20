//
//  VCRideRequest.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <RestKit/RestKit.h>
#import "Ticket.h"



@interface VCCommuterRideRequest : NSObject

@property (nonatomic) NSInteger customerId;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSNumber * departureLatitude;
@property (nonatomic, strong) NSNumber * departureLongitude;
@property (nonatomic, strong) NSString * departurePlaceName;
@property (nonatomic, strong) NSNumber * destinationLatitude;
@property (nonatomic, strong) NSNumber * destinationLongitude;
@property (nonatomic, strong) NSString * destinationPlaceName;
@property (nonatomic, strong) NSDate * pickupTime;
@property (nonatomic, strong) NSDate * returnPickupTime;
@property (nonatomic, strong) NSNumber * driving;
@property (nonatomic, strong) NSNumber * tripId;

+ (RKObjectMapping *) getMapping;

@end
