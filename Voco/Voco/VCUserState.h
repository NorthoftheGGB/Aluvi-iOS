//
//  VCUserState.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

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
#define kUserStateRideOffered @"Ride Offered"
#define kUserStateRideScheduled @"Ride Scheduled"
#define kUserStateRideAccepted @"Ride Accepted"
#define kUserStateRideStarted @"Ride Started"
#define kUserStateRideCompleted @"Ride Completed"

// placeholder class for user state tracking, enabling KVO

@interface VCUserState : NSObject


@property(nonatomic, strong) NSNumber * underwayRideId;
@property(nonatomic, strong) NSString * riderState;
@property(nonatomic, strong) NSString * driverState;
@property(nonatomic, strong) NSString * rideProcessState;
@property(nonatomic, strong) NSString * driveProcessState;

@property(nonatomic, strong) NSNumber * carId;

@property(nonatomic, strong) NSString * apiToken;


+ (VCUserState *) instance;
+ (BOOL) driverIsAvailable;

- (void) loginWithPhone:(NSString*) phone
               password: (NSString *) password
                success:(void ( ^ ) () )success
                failure:(void ( ^ ) () )failure;
- (void) logout;

@end
