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
#import "VCNotifications.h"

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


- (void) setProfile:(VCProfile *)profile {
    _profile = profile;
    [self cacheProfile];
}


-(void) cacheProfile {
    NSData * profileData = [NSKeyedArchiver archivedDataWithRootObject:_profile];
    [[NSUserDefaults standardUserDefaults] setObject:profileData forKey:kProfileDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) loginWithEmail:(NSString*) email
               password: (NSString *) password
                success:(void ( ^ ) () )success
                failure:(void ( ^ ) (RKObjectRequestOperation *operation, NSError *error) )failure {
    
    [VCUsersApi login:[RKObjectManager sharedManager] email:email password:password
              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                  VCLoginResponse * loginResponse = mappingResult.firstObject;
                  
                  [self setLoggedIn:loginResponse];
                  [[VCDebug sharedInstance] apiLog:@"API: Login success"];
                  [[VCDebug sharedInstance] setLoggedInUserIdentifier: email];
                  
                  
                  [[VCCommuteManager instance] loadFromServer];
                  
                  [[VCUserStateManager instance] refreshProfileWithCompletion:^{
                      [VCNotifications profileUpdated];
                      //success();
                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                      // nothing necessary to do
                  }];
                  
                  success();
                  
              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                  failure(operation, error);
              }];
    
}

- (void) setLoggedIn:(VCLoginResponse *) loginResponse {
    
    [VCApi setApiToken: loginResponse.token];
    self.riderState = loginResponse.riderState;
    if(loginResponse.driverState != nil){
        self.driverState = loginResponse.driverState;
    }
    
    //TODO refactor to utilize enqueueBatchOfObjectRequestOperations:progress:completion:
    [VCDevicesApi updateUserWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // can continue even with error
        // failure(operation, error);
    }];
    
   
}

- (void) createUser:( RKObjectManager *) objectManager
          firstName:(NSString*) firstName
           lastName:(NSString*) lastName
              email:(NSString*) email
           password:(NSString*) password
              phone:(NSString*) phone
       referralCode:(NSString*) referralCode
             driver:(NSNumber*) driver
            success:(void ( ^ ) () )success
            failure:(void ( ^ ) ( NSString* error))failure {
    
    [VCUsersApi createUser:objectManager firstName:firstName lastName:lastName email:email password:password phone:phone referralCode:referralCode driver:driver success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        VCLoginResponse * loginResponse = mappingResult.firstObject;
        if(loginResponse == nil){
            failure(@"Problem creating account.  Please try again");
            return;
        }
        
        [self setLoggedIn:loginResponse];
        [[VCDebug sharedInstance] apiLog:@"API: Login success"];
        [[VCDebug sharedInstance] setLoggedInUserIdentifier: email];
        success();
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
        failure(@"Problem creating user");
    }];
    

}

- (void) logoutWithCompletion: (void ( ^ ) () )success {
    [[VCCommuteManager instance] reset];
    [self finalizeLogout];
    success();
}

- (void) finalizeLogout {
    
    VCDevice * device = [[VCDevice alloc] init];
    device.userId = [NSNumber numberWithInt:0]; // unassign the push token
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

- (void) refreshProfileWithCompletion: (void ( ^ ) ( ))completion  failure:(void ( ^ ) (RKObjectRequestOperation *operation, NSError *error) )failure  {
    [VCUsersApi getProfile:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self loadProfileFromMappingResult:mappingResult];
        [self cacheProfile];
        [VCNotifications profileUpdated];
        completion();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
    }];
}

- (void) saveProfileWithCompletion: (void ( ^ ) ( ))completion  failure:(void ( ^ ) (RKObjectRequestOperation *operation, NSError *error) )failure
{
    [self cacheProfile];
    
    [VCUsersApi updateProfile:self.profile success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self loadProfileFromMappingResult:mappingResult];
        [self cacheProfile];
        [VCNotifications profileUpdated];
        completion();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
        failure(operation, error);
    }];
}


- (void) loadProfileFromMappingResult:(RKMappingResult *) mappingResult {
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

}



- (void) refreshProfileWithCompletion: (void ( ^ ) ( ))completion {
    [self refreshProfileWithCompletion:^{
        completion();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        //
    }];
}






@end
