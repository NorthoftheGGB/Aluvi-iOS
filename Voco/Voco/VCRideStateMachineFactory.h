//
//  VCRideStateMachineFactory.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TransitionKit.h>

#define kCreatedState @"created"
#define kRequestedState @"requested"
#define kDeclinedState @"declined"
#define kFoundState @"found"
#define kScheduledState @"scheduled"
#define kDriverCancelledState @"driver_cancelled"
#define kRiderCancelledState @"rider_cancelled"
#define kCompleteState @"complete"
#define kPaymentProblemState @"payment_problem"

@interface VCRideStateMachineFactory : NSObject

@property (nonatomic, strong) TKState * created;
@property (nonatomic, strong) TKState * requested;
@property (nonatomic, strong) TKState * declined;
@property (nonatomic, strong) TKState * found;
@property (nonatomic, strong) TKState * scheduled;
@property (nonatomic, strong) TKState * driverCancelled;
@property (nonatomic, strong) TKState * riderCancelled;
@property (nonatomic, strong) TKState * complete;
@property (nonatomic, strong) TKState * paymentProblem;

@property (nonatomic, strong) TKEvent * rideRequested;
@property (nonatomic, strong) TKEvent * rideCancelledByRider;
@property (nonatomic, strong) TKEvent * rideFound;
@property (nonatomic, strong) TKEvent * rideScheduled;
@property (nonatomic, strong) TKEvent * rideDeclined;
@property (nonatomic, strong) TKEvent * rideCancelledByDriver;
@property (nonatomic, strong) TKEvent * paymentProcessedSuccessfully;
@property (nonatomic, strong) TKEvent * paymentFailure;

+ (VCRideStateMachineFactory *) factory;
+ (TKStateMachine *) createOnDemandStateMachine;
+ (TKStateMachine *) createOnDemandStateMachineWithState:(NSString *) initialState;


@end
