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

@end



@implementation VCStateMachineManagedObject

@dynamic savedState;
@synthesize stateMachine = _stateMachine;
@synthesize forcedState;

-(id)init {
    self = [super init];
    if(self != nil) {
    }
    return self;
}


- (BOOL)canFireEvent:(id)eventOrEventName {
    return [_stateMachine canFireEvent:eventOrEventName];
}

- (BOOL)fireEvent:(id)eventOrEventName userInfo:(NSDictionary *)userInfo error:(NSError **)error{
#warning not firing events on state machine
    return true;
//   return [_stateMachine fireEvent:eventOrEventName userInfo:userInfo error:error];
}

- (void) assignStatesAndEvents:(TKStateMachine *) stateMachine {
    [NSException raise:@"Invoked abstract method" format:@"Invoked abstract method"];
}

- (NSString *) getInitialState {
    [NSException raise:@"Invoked abstract method" format:@"Invoked abstract method"];
    return nil;
}


- (void)awakeFromInsert {
    if([self primitiveValueForKey:@"savedState"] == nil){
        [self setPrimitiveValue:[self getInitialState] forKey:@"savedState"];
    }
    [self createStateMachine];
}

- (void)awakeFromFetch {
    if([self primitiveValueForKey:@"savedState"] == nil){
        [self setPrimitiveValue:[self getInitialState] forKey:@"savedState"];
    }

    [self addObserver:self forKeyPath:@"savedState" options:NSKeyValueObservingOptionNew context:nil];
    [self createStateMachine];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(![[_stateMachine.currentState name] isEqualToString:self.savedState]){
        [self createStateMachine];
    }
}

- (void) willSave {
    NSLog(@"%@", self.savedState);
    [self createStateMachine];
}


// Manually set the state, for restkit object mapping
- (void) setForcedState: (NSString*) state__ {
    self.savedState = state__;
}

// forced state never has a value
- (NSString *) forcedState {
    return @"";
}


/*
- (void) setSavedState:(NSString *)savedState__{
    [self willChangeValueForKey:@"savedState"];
    [self setPrimitiveValue:savedState__ forKey:@"savedState"];
    [self didChangeValueForKey:@"savedState"];
    [self createStateMachine];
}

- (NSString*) savedState {
    
}
 */

- (NSString *) state {
    NSString * state = [_stateMachine.currentState name];
    return state;
    //return [NSString stringWithFormat:@"%@ %@", state, self.savedState];
}


#pragma mark - State Machine

- (void)prepareStateMachine {
    for(TKEvent * event in _stateMachine.events){
        [event setDidFireEventBlock:^(TKEvent *event, TKTransition *transition) {
            self.savedState = transition.destinationState.name;
        }];
    }
}

- (void) createStateMachine {
    _stateMachine = [TKStateMachine new];
    [self assignStatesAndEvents:_stateMachine];
    [self prepareStateMachine];
    _stateMachine.initialState = [_stateMachine stateNamed:self.savedState];
    [_stateMachine activate];
}


@end
