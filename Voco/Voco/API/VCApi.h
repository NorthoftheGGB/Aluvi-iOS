//
//  VCApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

// rides API
#if ALPHA==1
#define API_BASE_URL @"http://voco-alpha.herokuapp.com/api/"
#elif RELEASE==1
#define API_BASE_URL @"http://voco-alpha.herokuapp.com/api/"
#elif TESTING==1
#define API_BASE_URL @"http://voco-test.herokuapp.com/api/"
#else
#define API_BASE_URL @"http://52.25.169.216:3000/api/" // AWS, nginx, single worker
//#define API_BASE_URL @"http://192.168.1.100:3000/api/" // At Home
//#define API_BASE_URL @"http://192.168.1.29:3000/api/" // The Grove


#endif

#define API_POST_RIDE_REQUEST @"rides/request"
#define API_POST_REQUEST_CANCELLED @"rides/request/cancel"
#define API_GET_RIDES_STATE @"rides/state"
#define API_POST_RIDE_ACCEPTED @"rides/accepted"
#define API_POST_RIDE_DECLINED @"rides/declined"
#define API_POST_DRIVER_CANCELLED @"rides/driver_cancelled"
#define API_POST_RIDER_CANCELLED @"rides/rider_cancelled"
#define API_POST_RIDE_PICKUP @"rides/pickup"
#define API_POST_FARE_COMPLETED @"rides/arrived"
#define API_DELETE_TRIP @"rides/trips/:trip_id"

#define API_GET_FARE_OFFERS @"rides/offers"
#define API_GET_ACTIVE_TICKETS @"rides/tickets"
#define API_GET_ACTIVE_FARES @"rides/fares"

#define API_GET_PAYMENTS @"rides/payments"
#define API_GET_EARNINGS @"rides/earnings"

#define API_ROUTE @"rides/route"

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
#define API_FILL_COMMUTER_PASS @"users/fill_commuter_pass"
#define API_CREATE_SUPPORT_REQUEST @"users/support"

// drivers
#define API_DRIVER_REGISTRATION @"drivers/driver_registration"
#define API_DRIVER_CLOCK_ON @"drivers/clock_on"
#define API_DRIVER_CLOCK_OFF @"drivers/clock_off"
#define API_GET_DRIVER_FARE_PATH_PATTERN @"drivers/fares/:id"

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
