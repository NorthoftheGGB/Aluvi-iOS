//
//  Ride.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Ride.h"
#import <TransitionKit.h>

@interface Ride ()

@property (nonatomic, strong) TKStateMachine * stateMachine;

@end

@implementation Ride

@dynamic ride_id;
@dynamic type;
@dynamic car_id;
@dynamic driver_id;
@dynamic state;
@dynamic requested_timestamp;
@dynamic estimated_arrival_time;
@dynamic origin_latitude;
@dynamic origin_longitude;
@dynamic meeting_point_latitude;
@dynamic meeting_point_longitude;
@dynamic destination_longitude;
@dynamic destination_latitude;
@dynamic request_id;

@synthesize stateMachine = _stateMachine;

- (id) init{
    self = [super init];
    if(self != nil){
        _stateMachine = [TKStateMachine new];
        
        // On Demand
        TKState * created = [TKState stateWithName:@"created"];
        TKState * requested = [TKState stateWithName:@"requested"];
        TKState * declined = [TKState stateWithName:@"declined"];
        TKState * found = [TKState stateWithName:@"found"];
        TKState * scheduled = [TKState stateWithName:@"scheduled"];
        TKState * driver_cancelled = [TKState stateWithName:@"driver_cancelled"];
        TKState * rider_cancelled = [TKState stateWithName:@"rider_cancelled"];
        TKState * complete = [TKState stateWithName:@"complete"];
        TKState * payment_problem = [TKState stateWithName:@"payment_problem"];
        
        TKEvent * ride_requested = [TKEvent eventWithName:@"ride_requested" transitioningFromStates:@[created] toState:requested];
        TKEvent * ride_canceled_by_rider = [TKEvent eventWithName:@"ride_canceled_by_rider" transitioningFromStates:@[requested, found, scheduled] toState:rider_cancelled];
        TKEvent * ride_found = [TKEvent eventWithName:@"ride_found" transitioningFromStates:@[requested] toState:found];
        TKEvent * ride_scheduled = [TKEvent eventWithName:@"ride_scheduled" transitioningFromStates:@[found] toState:scheduled];
        TKEvent * ride_declined = [TKEvent eventWithName:@"ride_declined" transitioningFromStates:@[created, requested] toState:declined];
        TKEvent * ride_cancelled_by_driver = [TKEvent eventWithName:@"ride_cancelled_by_driver" transitioningFromStates:@[scheduled] toState:driver_cancelled];
        TKEvent * payment_processed_successfully = [TKEvent eventWithName:@"payment_processed_successfully" transitioningFromStates:@[scheduled] toState:complete];
        TKEvent * payment_failure = [TKEvent eventWithName:@"payment_failure" transitioningFromStates:@[scheduled] toState:payment_problem];
        
        [_stateMachine addEvents:@[ride_requested, ride_canceled_by_rider, ride_found, ride_scheduled, ride_declined, ride_cancelled_by_driver, payment_processed_successfully, payment_failure]];
        
        // can we check self.state here?
        if(self.state != nil){
            // TODO how to save and restore state??
            self.state = @"created";
            _stateMachine.initialState = created;
        }
        [_stateMachine activate];
    }
    return self;
}

@end
