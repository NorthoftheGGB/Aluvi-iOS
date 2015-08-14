//
//  VCApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

// rides API
// Currently only have a single server deployed
//#if ALPHA==1
//#define API_BASE_URL @"http://voco-alpha.herokuapp.com/api/"
//#elif RELEASE==1
//#define API_BASE_URL @"http://voco-alpha.herokuapp.com/api/"
//#elif TESTING==1
//#define API_BASE_URL @"http://voco-test.herokuapp.com/api/"
//#else

//#define API_BASE_URL   // from build settings
//#define API_BASE_URL @"http://192.168.1.100:3000/api/" // At Home
//#define API_BASE_URL @"http://192.168.1.29:3000/api/" // The Grove


//#endif

#define API_POST_RIDE_PICKUP @"v2/rides/pickup"
#define API_POST_RIDE_COMPLETED @"v2/rides/arrived"
#define API_GET_PICKUP_POINTS @"v2/rides/pickup_points"
#define API_POST_RIDE_REQUEST @"v2/rides/request"

#define API_POST_RIDE_CANCELLED @"v2/rides/cancel"
#define API_DELETE_TRIP @"v2/rides/trips/:trip_id"


#define API_GET_ACTIVE_TICKETS @"v2/rides/tickets"

#define API_GET_PAYMENTS @"rides/payments"
#define API_GET_EARNINGS @"rides/earnings"

#define API_ROUTE @"v2/rides/route"

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
#define API_USER_PROFILE @"v2/users/profile"
#define API_FILL_COMMUTER_PASS @"users/fill_commuter_pass"
#define API_CREATE_SUPPORT_REQUEST @"users/support"

// drivers
#define API_DRIVER_REGISTRATION @"drivers/driver_registration"


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

@end
