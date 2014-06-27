//
//  VCApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

// rides API
#if 1 //RELEASE==1
#define API_BASE_URL @"http://54.187.62.13:3000/api/"
#else
#define API_BASE_URL @"http://192.168.1.109:3000/api/"
#endif

#define API_POST_RIDE_REQUEST @"rides/request"
#define API_POST_REQUEST_CANCELLED @"rides/request/cancel"
#define API_GET_RIDES_STATE @"rides/state"
#define API_POST_RIDE_ACCEPTED @"rides/accepted"
#define API_POST_RIDE_DECLINED @"rides/declined"
#define API_POST_DRIVER_CANCELLED @"rides/driver_cancelled"
#define API_POST_RIDER_CANCELLED @"rides/rider_cancelled"
#define API_POST_RIDE_PICKUP @"rides/pickup"
#define API_POST_RIDE_ARRIVED @"rides/arrived"

#define API_GET_RIDE_OFFERS @"rides/offers/"
#define API_GET_SCHEDULED_RIDES @"rides/"

// geo API
#define API_GEO_CAR @"geo/car/"
#define API_GEO_CAR_PATH_PATTERN @"geo/car/:id"
#define API_GEO_RIDER @"geo/rider"
#define API_GEO_CARS @"geo/cars"

// devices API - RESTful
#define API_DEVICES @"devices/"

// users API
#define API_USERS @"users"
#define API_LOGIN @"users/login"
#define API_FORGOT_PASSWORD @"users/forgot_password"
#define API_DRIVER_INTERESTED @"users/driver_interested"
#define API_USER_STATE @"users/state"

// drivers
#define API_DRIVER_REGISTRATION @"drivers/driver_registration"
#define API_DRIVER_CLOCK_ON @"drivers/clock_on"
#define API_DRIVER_CLOCK_OFF @"drivers/clock_off"

// state
#define API_TOKEN_KEY @"API_TOKEN"

@interface VCApi : NSObject

//Setup
+ (void) setup;

// Login
+ (NSString *) apiToken;
+ (void) setApiToken: (NSString *) token;
+ (BOOL) loggedIn;
+ (void) clearApiToken;

// path helpers
+ (NSString *) devicesObjectPathPattern;
+ (NSString *) getRideOffersPath:(NSNumber*) driverId;
+ (NSString *) getPutGeoCarPath:(NSNumber *) carId;

@end
