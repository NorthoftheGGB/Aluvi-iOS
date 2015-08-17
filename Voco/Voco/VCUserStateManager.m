//
//  VCUserState.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCUserStateManager.h"
#import <MBProgressHUD.h>
#import "VCUsersApi.h"
#import "VCApi.h"
#import "VCDevicesApi.h"
#import "VCLoginResponse.h"
#import "VCUserStateResponse.h"
#import "VCInterfaceManager.h"
#import "VCDriverApi.h"
#import "VCCommuteManager.h"
#import "Car.h"

NSString *const VCUserStateDriverStateKeyPath = @"driverState";

#define kRideProcessStateKey @"kRideProcessStateKey"
#define kDriveProcessStateKey @"kDriveProcessStateKey"
#define kRiderStateKey @"kRiderStateKey"
#define kDriverStateKey @"kDriverStateKey"
#define kRideIdKey @"kRideIdKey"
#define kProfileDataKey @"kProfileDataKey"

static VCUserStateManager *sharedSingleton;

@implementation VCUserStateManager

+ (VCUserStateManager *) instance {
    if(sharedSingleton == nil){
        sharedSingleton = [[VCUserStateManager alloc] init];
    }
    return sharedSingleton;
}


- (id) init {
    self = [super init];
    if(self != nil){
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        _rideProcessState = [userDefaults objectForKey:kRideProcessStateKey];
        _driveProcessState = [userDefaults objectForKey:kDriveProcessStateKey];
        _riderState = [userDefaults objectForKey:kRiderStateKey];
        _driverState = [userDefaults objectForKey:kDriverStateKey];
        //_underwayFareId = [userDefaults objectForKey:kRideIdKey];
        NSData * profileData = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileDataKey];
        if(profileData != nil) {
            @try {
                _profile = [NSKeyedUnarchiver unarchiveObjectWithData:profileData];
            }
            @catch (NSException *exception) {
                //
            }
            @finally {
                //
            }
        }

    }
    return self;
}


/*
- (void) setUnderwayFareId:(NSNumber *)rideId {
    _underwayFareId = rideId;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_underwayFareId forKey:kRideIdKey];
    [userDefaults synchronize];
    
}
 */
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

- (void) setProfile:(VCProfile *)profile {
    _profile = profile;
    [self saveProfile];
}

- (void) saveProfile {
    NSData * profileData = [NSKeyedArchiver archivedDataWithRootObject:_profile];
    [[NSUserDefaults standardUserDefaults] setObject:profileData forKey:kProfileDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loginWithEmail:(NSString*) phone
               password: (NSString *) password
                success:(void ( ^ ) () )success
                failure:(void ( ^ ) (RKObjectRequestOperation *operation, NSError *error) )failure {
    
    [VCUsersApi login:[RKObjectManager sharedManager] email:phone password:password
              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                  VCLoginResponse * loginResponse = mappingResult.firstObject;
                  self.riderState = loginResponse.riderState;
                  if(loginResponse.driverState != nil){
                      self.driverState = loginResponse.driverState;
                  }
                  
                  [[VCCommuteManager instance] loadFromServer];
                  
                  //TODO refactor to utilize enqueueBatchOfObjectRequestOperations:progress:completion:
                  [VCDevicesApi updateUserWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                      
                      [VCUsersApi getProfile:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          [self setProfile: mappingResult.firstObject];
                          success();
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          failure(operation, error);
                      }];
                      
                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                      failure(operation, error);
                  }];
                  
              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                  failure(operation, error);
              }];
    
}

- (void) logoutWithCompletion: (void ( ^ ) () )success {
    
    
    [self finalizeLogout];
    success();
}

- (void) finalizeLogout {
    
    VCDevice * device = [[VCDevice alloc] init];
    device.userId = [NSNumber numberWithInt:0]; // unassign the push token
    device.pushToken = @"";
    [VCDevicesApi patchDevice:device success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self clearUser];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];

}

- (void) clearUser {
    [VCApi clearApiToken];
    [self clearUserState];
    [self setProfile:nil];
    [VCCoreData clearUserData];
    [[VCDebug sharedInstance] clearLoggedInUserIdentifier];
    [[VCCommuteManager instance] clear];
    [[VCInterfaceManager instance] showRiderSigninInterface];
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
    [userDefaults removeObjectForKey:kProfileDataKey];
    [userDefaults synchronize];
    //_underwayFareId = nil;
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
    //_underwayFareId = nil;
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

- (BOOL) isHovDriver {
    if([self.driverState isEqualToString:kDriverStateActive]){
        return YES;
    }
    return NO;
}



- (void) refreshProfileWithCompletion: (void ( ^ ) ( ))completion {
    [VCUsersApi getProfile:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSArray * array = [mappingResult array];
        VCProfile * profile;
        Car * car;
        profile.carId = nil;
        if([array[0] isKindOfClass:[VCProfile class]]){
            profile = mappingResult.firstObject;
            if([array count] > 1) {
                car = array[1];
            }
        } else {
            profile = array[1];
            car = mappingResult.firstObject;
        }
        
        profile.carId = car.id;
        [self setProfile: profile];
        completion();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
    }];

}






@end
