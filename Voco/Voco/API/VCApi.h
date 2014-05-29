//
//  VCApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

// rides API
#define API_BASE_URL @"http://10.112.18.138:3000/"
#define API_POST_RIDE_REQUEST @"rides/request"
#define API_GET_RIDES_STATE @"rides/state"
#define API_POST_RIDE_ACCEPTED @"rides/accepted"
#define API_POST_RIDE_DECLINED @"rides/declined"
#define API_POST_DRIVER_CANCELLED @"rides/driver_cancelled"
#define API_POST_RIDER_CANCELLED @"rides/rider_cancelled"
#define API_POST_RIDE_PICKUP @"rides/pickup"
#define API_POST_RIDE_ARRIVED @"rides/arrived"

// geo API
#define API_GEO_CAR @"geo/car"
#define API_GEO_RIDER @"geo/rider"
#define API_GEO_CARS @"geo/cars"

// devices API - RESTful
#define API_DEVICES @"devices/"

@interface VCApi : NSObject

+ (NSString *) devicesObjectPathPattern;

@end
