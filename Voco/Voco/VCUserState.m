//
//  VCUserState.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCUserState.h"
#import "VCUsersApi.h"
#import "VCApi.h"
#import "VCDevicesApi.h"

static VCUserState *sharedSingleton;

@implementation VCUserState

+ (VCUserState *) instance {
    if(sharedSingleton == nil){
        sharedSingleton = [[VCUserState alloc] init];
        NSLog(@"%@", @"Warning: hard coded car id");
        sharedSingleton.carId = [NSNumber numberWithInt:1];
    }
    return sharedSingleton;
}

+ (BOOL) driverIsAvailable {
    return true; // assumption for now
}

- (id) init {
    self = [super init];
    if(self != nil){
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        _rideId = [userDefaults objectForKey:@"rideId"];
        _riderState = [userDefaults objectForKey:@"riderState"];
        _driverState = [userDefaults objectForKey:@"driverState"];
    }
    return self;
}

- (void) saveState {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_rideId forKey:@"rideId"];
    [userDefaults setObject:_riderState forKey:@"riderState"];
    [userDefaults setObject:_driverState forKey:@"driverState"];
    [userDefaults synchronize];
}

- (void) loginWithPhone:(NSString*) phone
               password: (NSString *) password
                success:(void ( ^ ) () )success
                failure:(void ( ^ ) () )failure {
    
    [VCUsersApi login:[RKObjectManager sharedManager] phone:phone password:password
              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                  [VCDevicesApi updateUserWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                      success();
                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                      [WRUtilities criticalError:error];
                  }];
                  
              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                  failure();
              }];
    
}

- (void) logout {
    
    [VCApi clearApiToken];
    [VCDevicesApi updateUserWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [VCCoreData clearUserData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
    }];
}

@end
