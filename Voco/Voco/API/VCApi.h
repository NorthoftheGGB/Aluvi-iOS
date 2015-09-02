//
//  VCApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_POST_RIDE_PICKUP @"v2/rides/pickup"
#define API_POST_RIDE_COMPLETED @"v2/rides/arrived"
#define API_GET_PICKUP_POINTS @"v2/rides/pickup_points"
#define API_POST_RIDE_REQUEST @"v2/rides/commute"

#define API_POST_RIDE_CANCELLED @"v2/rides/cancel"
#define API_DELETE_TRIP @"v2/rides/trips/:trip_id"


#define API_GET_ACTIVE_TICKETS @"v2/rides/tickets"

#define API_GET_RECEIPTS @"v2/rides/receipts"


#define API_ROUTE @"v2/rides/route"

// geo API
#define API_GEO_DRIVER_PATH @"geo/drivers/:objectId"
#define API_GEO_DRIVERS @"geo/drivers"
#define API_GEO_RIDER_PATH @"geo/rider"
#define API_GEO_RIDERS @"geo/riders"

// devices API - RESTful
#define API_DEVICES @"devices/"

// users API
#define API_USERS @"v2/users"
#define API_LOGIN @"v2/users/login"
#define API_FORGOT_PASSWORD @"v2/users/forgot_password"
#define API_DRIVER_INTERESTED @"v2/users/driver_interested"
#define API_USER_STATE @"v2/users/state"
#define API_USER_PROFILE @"v2/users/profile"
#define API_FILL_COMMUTER_PASS @"v2users/fill_commuter_pass"
#define API_CREATE_SUPPORT_REQUEST @"v2/users/support"

// drivers
#define API_DRIVER_REGISTRATION @"drivers/driver_registration"
#define API_CAR_UPDATE @"drivers/car"


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
