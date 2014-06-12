//
//  VCRideStateMachineFactory.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideStateMachineFactory.h"

@interface VCRideStateMachineFactory ()

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
@end

@implementation VCRideStateMachineFactory

static VCRideStateMachineFactory *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[VCRideStateMachineFactory alloc] init];
    }
}

+ (VCRideStateMachineFactory *) factory {
    if(sharedSingleton == nil){
        [VCRideStateMachineFactory initialize];
    }
    return sharedSingleton;
}

- (id) init {
    self = [super init];
    if(self != nil) {
    _created = [TKState stateWithName:@"created"];
    _requested = [TKState stateWithName:@"requested"];
    _declined = [TKState stateWithName:@"declined"];
    _found = [TKState stateWithName:@"found"];
    _scheduled = [TKState stateWithName:@"scheduled"];
    _driverCancelled = [TKState stateWithName:@"driver_cancelled"];
    _riderCancelled = [TKState stateWithName:@"rider_cancelled"];
    _complete = [TKState stateWithName:@"complete"];
    _paymentProblem = [TKState stateWithName:@"payment_problem"];
    
    _rideRequested = [TKEvent eventWithName:@"ride_requested" transitioningFromStates:@[_created] toState:_requested];
    _rideCancelledByRider = [TKEvent eventWithName:@"ride_canceled_by_rider" transitioningFromStates:@[_requested, _found, _scheduled] toState:_riderCancelled];
    _rideFound = [TKEvent eventWithName:@"ride_found" transitioningFromStates:@[_requested] toState:_found];
    _rideScheduled = [TKEvent eventWithName:@"ride_scheduled" transitioningFromStates:@[_found] toState:_scheduled];
    _rideDeclined = [TKEvent eventWithName:@"ride_declined" transitioningFromStates:@[_created, _requested] toState:_declined];
    _rideCancelledByDriver = [TKEvent eventWithName:@"ride_cancelled_by_driver" transitioningFromStates:@[_scheduled] toState:_driverCancelled];
    _paymentProcessedSuccessfully = [TKEvent eventWithName:@"payment_processed_successfully" transitioningFromStates:@[_scheduled] toState:_complete];
    _paymentFailure = [TKEvent eventWithName:@"payment_failure" transitioningFromStates:@[_scheduled] toState:_paymentProblem];
    
    }
    return self;
}



- (TKStateMachine *) createOnDemandStateMachine {
    TKStateMachine * stateMachine = [TKStateMachine new];
    [stateMachine addEvents:@[_rideRequested, _rideCancelledByRider, _rideFound, _rideScheduled, _rideDeclined, _rideCancelledByDriver, _paymentProcessedSuccessfully, _paymentFailure]];
    stateMachine.initialState = _created;
    return stateMachine;
}

+ (TKStateMachine *) createOnDemandStateMachine {
    TKStateMachine * stateMachine = [[self factory] createOnDemandStateMachine];
    [stateMachine activate];
    return stateMachine;
}




@end