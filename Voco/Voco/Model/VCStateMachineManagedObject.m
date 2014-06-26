//
//  VCStateMachineManagedObject.m
//  Voco
//
//  Created by Matthew Shultz on 6/26/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCStateMachineManagedObject.h"

@interface VCStateMachineManagedObject ()

@property (nonatomic, strong) TKStateMachine * stateMachine;
@property (nonatomic, retain) NSString * savedState;

@end



@implementation VCStateMachineManagedObject

@dynamic savedState;
@synthesize stateMachine = _stateMachine;


- (BOOL)canFireEvent:(id)eventOrEventName {
    return [_stateMachine canFireEvent:eventOrEventName];
}

- (BOOL)fireEvent:(id)eventOrEventName userInfo:(NSDictionary *)userInfo error:(NSError **)error{
   return [_stateMachine fireEvent:eventOrEventName userInfo:userInfo error:error];
}

- (void) assignStatesAndEvents:(TKStateMachine *) stateMachine {
    [NSException raise:@"Invoked abstract method" format:@"Invoked abstract method"];
}

- (void)awakeFromInsert {
    _stateMachine = [VCRideStateMachineFactory createOnDemandStateMachine];
}

- (void)awakeFromFetch {
    _stateMachine = [VCRideStateMachineFactory createOnDemandStateMachineWithState:self.savedState];
}


@end
