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
#import "VCDevicesApi.h"
#import "VCObjectRequestOperation.h"
#import "VCAppDelegate.h"
#import "VCCoreData.h"
#import "VCGeoApi.h"

#define kSecretApiKey @"asp03092jsdklfj023jsdf"

static NSString * apiToken;

@implementation VCApi

+ (void) setup {
    RKObjectManager * objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
    [objectManager registerRequestOperationClass:[VCObjectRequestOperation class]];
    objectManager.managedObjectStore = [VCCoreData managedObjectStore];
    
    [VCRiderApi setup: objectManager];
    [VCDriverApi setup: objectManager];
    [VCUsersApi setup: objectManager];
    [VCDevicesApi setup:objectManager];
    [VCGeoApi setup:objectManager];
        
    [self setApiToken: [[NSUserDefaults standardUserDefaults] stringForKey:API_TOKEN_KEY]];
    
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);


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

+ (void) clearApiToken {
    apiToken = nil;
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
    return [NSString stringWithFormat:@"%@%@", API_GET_FARE_OFFERS, driverId];
}



@end
