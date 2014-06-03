//
//  Transport.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Drive.h"
#import <TransitionKit.h>

@interface Drive ()

@property (nonatomic, strong) TKStateMachine * stateMachine;

@end

@implementation Drive

@dynamic car_id;
@dynamic destination_latitude;
@dynamic destination_longitude;
@dynamic driver_id;
@dynamic estimated_arrival_time;
@dynamic meeting_point_latitude;
@dynamic meeting_point_longitude;
@dynamic origin_latitude;
@dynamic origin_longitude;
@dynamic request_id;
@dynamic requested_timestamp;
@dynamic ride_id;
@dynamic state;
@dynamic type;

@synthesize stateMachine = _stateMachine;

- (id) init{
    self = [super init];
    if(self != nil){
        _stateMachine = [TKStateMachine new];
        
        // The state and events can be created in a separate class
        // (which can also be used to translated state string to state and vice verson)
        
    }
    return self;
}

@end
