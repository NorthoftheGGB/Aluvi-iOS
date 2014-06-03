//
//  VCApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

// rides API
#define API_BASE_URL @"http://192.168.1.108:3000/api/"
#define API_POST_RIDE_REQUEST @"rides/request"
#define API_GET_RIDES_STATE @"rides/state"
#define API_POST_RIDE_ACCEPTED @"rides/accepted"
#define API_POST_RIDE_DECLINED @"rides/declined"
#define API_POST_DRIVER_CANCELLED @"rides/driver_cancelled"
#define API_POST_RIDER_CANCELLED @"rides/rider_cancelled"
#define API_POST_RIDE_PICKUP @"rides/pickup"
#define API_POST_RIDE_ARRIVED @"rides/arrived"

// TODO there must be a better way to deal with path patterns and params via restkit or other library
#define API_GET_RIDE_OFFERS @"rides/offers/"
#define API_GET_RIDE_OFFERS_PATH_PATTERN @"rides/offers/:id"

#define API_GET_SCHEDULED_RIDES @"rides/"
#define API_GET_SCHEDULED_RIDES_PATH_PATTERN @"rides/:rider_id"


// geo API
#define API_GEO_CAR @"geo/car"
#define API_GEO_RIDER @"geo/rider"
#define API_GEO_CARS @"geo/cars"

// devices API - RESTful
#define API_DEVICES @"devices/"

@interface VCApi : NSObject

+ (NSString *) devicesObjectPathPattern;
+ (NSString *) getRideOffersPath:(NSNumber*) driverId;
+ (NSString *) getScheduledRidesPath:(NSNumber*) riderId;

@end
