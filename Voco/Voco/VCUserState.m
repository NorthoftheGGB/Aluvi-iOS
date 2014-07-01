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
#import "VCUserStateResponse.h"
#import "VCInterfaceModes.h"
#import "VCDriverApi.h"

#define kRideProcessStateKey @"kRideProcessStateKey"
#define kDriveProcessStateKey @"kDriveProcessStateKey"
#define kRiderStateKey @"kRiderStateKey"
#define kDriverStateKey @"kDriverStateKey"
#define kRideIdKey @"kRideIdKey"

static VCUserState *sharedSingleton;

@implementation VCUserState

@synthesize riderState, driverState;

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
        riderState = [userDefaults objectForKey:kRiderStateKey];
        driverState = [userDefaults objectForKey:kDriverStateKey];
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
- (void) setRiderState:(NSString *) __riderState {
    riderState = __riderState;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.riderState forKey:kRiderStateKey];
    [userDefaults synchronize];
}
- (void) setDriverState:(NSString *) __driverState {
    driverState = __driverState;
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
    
    [VCApi clearApiToken];
    [VCDevicesApi updateUserWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self clearUserState];
        [VCCoreData clearUserData];
        [VCInterfaceModes showRiderSigninInterface];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
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
    _underwayRideId = nil;
    _rideProcessState = nil;
    _driveProcessState = nil;
    self.riderState = nil;
    self.driverState = nil;
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


@end
