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
#import "VCLoginResponse.h"

#define kRideProcessStateKey @"kRideProcessStateKey"
#define kDriveProcessStateKey @"kDriveProcessStateKey"
#define kRiderStateKey @"kRiderStateKey"
#define kDriverStateKey @"kDriverStateKey"
#define kRideIdKey @"kRideIdKey"

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
        _rideProcessState = [userDefaults objectForKey:kRideProcessStateKey];
        _driveProcessState = [userDefaults objectForKey:kDriveProcessStateKey];
        _riderState = [userDefaults objectForKey:kRiderStateKey];
        _driverState = [userDefaults objectForKey:kDriverStateKey];
    }
    return self;
}


- (void) setUnderwayRideId:(NSNumber *)rideId {
    _underwayRideId = rideId;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_underwayRideId forKey:kRideIdKey];
    [userDefaults synchronize];
    
}
- (void) setRideProcessState:(NSString *)rideProcessState {
    _rideProcessState = rideProcessState;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_rideProcessState forKey:kRideProcessStateKey];
    [userDefaults synchronize];
}
- (void) setDriveProcessState:(NSString *)driveProcessState {
    _driveProcessState = driveProcessState;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_driveProcessState forKey:kDriveProcessStateKey];
    [userDefaults synchronize];
}
- (void) setRiderState:(NSString *)riderState {
    _riderState = riderState;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_riderState forKey:kRiderStateKey];
    [userDefaults synchronize];
}
- (void) setDriverState:(NSString *)driverState {
    _driverState = driverState;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_driverState forKey:kDriverStateKey];
    [userDefaults synchronize];
}

- (void) loginWithPhone:(NSString*) phone
               password: (NSString *) password
                success:(void ( ^ ) () )success
                failure:(void ( ^ ) () )failure {
    
    [VCUsersApi login:[RKObjectManager sharedManager] phone:phone password:password
              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                  VCLoginResponse * loginResponse = mappingResult.firstObject;
                  _riderState = loginResponse.riderState;
                  _driverState = loginResponse.driverState;
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
        [self clearUserState];
        [VCCoreData clearUserData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
    }];
}

- (void) clearUserState {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kRideIdKey];
    [userDefaults removeObjectForKey:kRideProcessStateKey];
    [userDefaults removeObjectForKey:kDriveProcessStateKey];
    [userDefaults removeObjectForKey:kDriverStateKey];
    [userDefaults removeObjectForKey:kRiderStateKey];
    [userDefaults synchronize];
    _underwayRideId = nil;
    _rideProcessState = nil;
    _driveProcessState = nil;
    _riderState = nil;
    _driverState = nil;
}

@end
