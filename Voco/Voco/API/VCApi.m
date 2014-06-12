//
//  VCApi.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCApi.h"
#import <RestKit.h>
#import "VCApi.h"
#import "VCRiderApi.h"
#import "VCDriverApi.h"
#import "VCUsersApi.h"
#import "VCObjectRequestOperation.h"
#import "VCAppDelegate.h"

static NSString * apiToken;

@implementation VCApi

+ (void) setup {
    RKObjectManager * objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
    [objectManager registerRequestOperationClass:[VCObjectRequestOperation class]];
    
    [VCRiderApi setup: objectManager];
    [VCDriverApi setup: objectManager];
    [VCUsersApi setup: objectManager];
    
    objectManager.managedObjectStore = [((VCAppDelegate*)[UIApplication sharedApplication].delegate) managedObjectStore];
    
    
    [self setApiToken: [[NSUserDefaults standardUserDefaults] stringForKey:API_TOKEN_KEY]];
}

+ (NSString *) apiToken {
    return apiToken;
}

+ (void) setApiToken: (NSString *) token {
    apiToken = token;
    [[NSUserDefaults standardUserDefaults] setObject:apiToken forKey:API_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithToken:apiToken];
}

+ (BOOL) loggedIn {
    if(apiToken == nil){
        return NO;
    } else {
        return YES;
    }
}



+ (NSString *) devicesObjectPathPattern {
    return [NSString stringWithFormat:@"%@:uuid", API_DEVICES];
}

+ (NSString *) getRideOffersPath:(NSNumber*) driverId {
    return [NSString stringWithFormat:@"%@%@", API_GET_RIDE_OFFERS, driverId];
}

+ (NSString *) getScheduledRidesPath:(NSNumber*) riderId {
    return [NSString stringWithFormat:@"%@%@", API_GET_SCHEDULED_RIDES, riderId];
}

+ (NSString *) getPutGeoCarPath:(NSNumber *) carId {
    return [NSString stringWithFormat:@"%@%@", API_GEO_CAR, carId];
}

@end
