//
//  VCApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

// rides API
#if RELEASE==1
#define API_BASE_URL @"http://54.187.62.13:3000/api/"
#elif TESTING==1
#define API_BASE_URL @"http://voco-test-server.herokuapp.com/api/"
#else
#define API_BASE_URL @"http://192.168.1.117:3000/api/"
//#define API_BASE_URL @"http://voco-alpha.herokuapp.com/api/"
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

#define API_GET_RIDE_OFFERS @"rides/offers"
#define API_GET_ACTIVE_REQUESTS @"rides/requests"
#define API_GET_ACTIVE_RIDES @"rides/rides"

#define API_GET_PAYMENTS @"rides/payments"

// geo API
#define API_GEO_DRIVER_PATH @"geo/drivers/:objectId"
#define API_GEO_DRIVERS @"geo/drivers"
#define API_GEO_RIDER_PATH @"geo/rider"
#define API_GEO_RIDERS @"geo/riders"

// devices API - RESTful
#define API_DEVICES @"devices/"

// users API
#define API_USERS @"users"
#define API_LOGIN @"users/login"
#define API_FORGOT_PASSWORD @"users/forgot_password"
#define API_DRIVER_INTERESTED @"users/driver_interested"
#define API_USER_STATE @"users/state"
#define API_USER_PROFILE @"users/profile"

// drivers
#define API_DRIVER_REGISTRATION @"drivers/driver_registration"
#define API_DRIVER_CLOCK_ON @"drivers/clock_on"
#define API_DRIVER_CLOCK_OFF @"drivers/clock_off"
#define API_GET_DRIVER_RIDE_PATH_PATTERN @"drivers/rides/:id"

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

@end
