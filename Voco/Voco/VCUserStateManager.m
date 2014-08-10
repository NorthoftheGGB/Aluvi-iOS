//
//  VCUserState.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCUserStateManager.h"
#import "VCUsersApi.h"
#import "VCApi.h"
#import "VCDevicesApi.h"
#import "VCLoginResponse.h"
#import "VCUserStateResponse.h"
#import "VCInterfaceManager.h"
#import "VCDriverApi.h"
#import "VCCommuteManager.h"

NSString *const VCUserStateDriverStateKeyPath = @"driverState";

#define kRideProcessStateKey @"kRideProcessStateKey"
#define kDriveProcessStateKey @"kDriveProcessStateKey"
#define kRiderStateKey @"kRiderStateKey"
#define kDriverStateKey @"kDriverStateKey"
#define kRideIdKey @"kRideIdKey"

static VCUserStateManager *sharedSingleton;

@implementation VCUserStateManager

+ (VCUserStateManager *) instance {
    if(sharedSingleton == nil){
        sharedSingleton = [[VCUserStateManager alloc] init];
    }
    return sharedSingleton;
}

+ (BOOL) driverIsAvailable {
    // Will need a better way to swith on this
    if([self instance].underwayFareId == nil){
        return YES;
    } else {
        return NO;
    }
}

- (id) init {
    self = [super init];
    if(self != nil){
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        _rideProcessState = [userDefaults objectForKey:kRideProcessStateKey];
        _driveProcessState = [userDefaults objectForKey:kDriveProcessStateKey];
        _riderState = [userDefaults objectForKey:kRiderStateKey];
        _driverState = [userDefaults objectForKey:kDriverStateKey];
        _underwayFareId = [userDefaults objectForKey:kRideIdKey];
    }
    return self;
}


- (void) setUnderwayFareId:(NSNumber *)rideId {
    _underwayFareId = rideId;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_underwayFareId forKey:kRideIdKey];
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
- (void) setRiderState:(NSString *) __riderState {
    _riderState = __riderState;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.riderState forKey:kRiderStateKey];
    [userDefaults synchronize];
}
- (void) setDriverState:(NSString *) __driverState {
    _driverState = __driverState;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.driverState forKey:kDriverStateKey];
    [userDefaults synchronize];
}

- (void) loginWithPhone:(NSString*) phone
               password: (NSString *) password
                success:(void ( ^ ) () )success
                failure:(void ( ^ ) () )failure {
    
    [VCUsersApi login:[RKObjectManager sharedManager] phone:phone password:password
              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                  VCLoginResponse * loginResponse = mappingResult.firstObject;
                  self.riderState = loginResponse.riderState;
                  if(loginResponse.driverState != nil){
                      self.driverState = loginResponse.driverState;
                  }
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
    
    if(self.driverState != nil && [self.driverState isEqualToString:kDriverStateOnDuty] ){
        [VCDriverApi clockOffWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self finalizeLogout];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {

        }];
    } else {
        [self finalizeLogout];
    }
}

- (void) finalizeLogout {
    
    VCDevice * device = [[VCDevice alloc] init];
    device.userId = [NSNumber numberWithInt:0]; // unassign the push token
    [VCDevicesApi patchDevice:device success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [VCApi clearApiToken];
        [self clearUserState];
        [VCCoreData clearUserData];
        [[VCInterfaceManager instance] showRiderSigninInterface];
        [[VCDebug sharedInstance] clearLoggedInUserIdentifier];
        [[VCCommuteManager instance] clear];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];

}

- (void) synchronizeUserState {
    [VCUsersApi getUserState:[RKObjectManager sharedManager]
                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                         VCUserStateResponse * response = mappingResult.firstObject;
                         self.riderState = response.riderState;
                         if(response.driverState != nil) {
                             self.driverState = response.driverState;
                         }
                     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                         NSLog(@"Could not synchronize user state");
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
    _underwayFareId = nil;
    _rideProcessState = nil;
    _driveProcessState = nil;
    _riderState = nil;
    _driverState = nil;

}

- (void) clearRideState {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kRideIdKey];
    [userDefaults removeObjectForKey:kRideProcessStateKey];
    [userDefaults removeObjectForKey:kDriveProcessStateKey];
    [userDefaults synchronize];
    _underwayFareId = nil;
    _rideProcessState = nil;
    _driveProcessState = nil;
}


- (BOOL) isLoggedIn {
    if(self.riderState != nil || self.driverState != nil ){
        return YES;
    } else {
        return NO;
    }
}

- (void) clockOnWithSuccess: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                    failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    [VCDriverApi clockOnWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.driverState = kDriverStateOnDuty;
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
    
}

- (void) clockOffWithSuccess: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                     failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    [VCDriverApi clockOffWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.driverState = kDriverStateActive;
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

- (void) updateCommuterPreferences {
    
}





@end
