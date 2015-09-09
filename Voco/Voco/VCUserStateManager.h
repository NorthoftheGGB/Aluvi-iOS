//
//  VCUserState.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "VCProfile.h"

NSString *const VCUserStateDriverStateKeyPath;

#define kRiderStateRegistered @"registered"
#define kRiderStateActiove @"active"
#define kRiderStatePaymentProblem @"payment_problem"
#define kRiderStateSuspended @"suspended"

#define kDriverStateInterested @"interested"
#define kDriverStateApproved @"approved"
#define kDriverStateDenied @"denied"
#define kDriverStateRegistered @"registered"
#define kDriverStateActive @"active"
#define kDriverStateSuspended @"suspended"
#define kDriverStateOnDuty @"on_duty"

// These are states for dealing with rides, from the .1 platform
#define kUserStateIdle @"Idle"
#define kUserStateRideScheduled @"Ride Scheduled"
#define kUserStateRideAccepted @"Ride Accepted"
#define kUserStateRideStarted @"Ride Started"
#define kUserStateRideCompleted @"Ride Completed"

@interface VCUserStateManager : NSObject

@property(nonatomic, strong) NSString * riderState;
@property(nonatomic, strong) NSString * driverState;
@property(nonatomic, strong) NSString * rideProcessState;
@property(nonatomic, strong) NSString * driveProcessState;

@property(nonatomic, strong) NSString * apiToken;

@property(nonatomic, strong) VCProfile * profile;

// commuter preferences
@property(nonatomic, strong) CLLocation * commuteOrigin;
@property(nonatomic, strong) CLLocation * commuteDestination;
@property(nonatomic, strong) NSString * commuteDepartureTime;
@property(nonatomic, strong) NSString * commuteReturnTime;

+ (VCUserStateManager *) instance;

- (void) loginWithEmail:(NSString*) email
               password: (NSString *) password
                success:(void ( ^ ) () )success
                failure:(void ( ^ ) (RKObjectRequestOperation *operation, NSError *error) )failure;
- (void) createUser:( RKObjectManager *) objectManager
          firstName:(NSString*) firstName
           lastName:(NSString*) lastName
              email:(NSString*) email
           password:(NSString*) password
              phone:(NSString*) phone
       referralCode:(NSString*) referralCode
             driver:(NSNumber*) driver
            success:(void ( ^ ) () )success
            failure:(void ( ^ ) ( NSString* error))failure;

- (void) logoutWithCompletion: (void ( ^ ) () )success;
- (void) finalizeLogout;
- (void) synchronizeUserState;
- (BOOL) isLoggedIn;
- (BOOL) isHovDriver;


- (void) clearRideState;
- (void) clearUser;

- (void) refreshProfileWithCompletion: (void ( ^ ) ( ))completion;
- (void) saveProfileWithCompletion: (void ( ^ ) ( ))completion  failure:(void ( ^ ) (RKObjectRequestOperation *operation, NSError *error) )failure;
- (void) updateDefaultCard: (NSString *) token success:(void ( ^ ) ( ))success  failure:(void ( ^ ) (RKObjectRequestOperation *operation, NSError *error) )failure;
- (void) updateRecipientCard: (NSString *) token success:(void ( ^ ) ( ))success  failure:(void ( ^ ) (RKObjectRequestOperation *operation, NSError *error) )failure;

@end
