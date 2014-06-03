//
//  VCRideStateMachineFactory.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TransitionKit.h>


@interface VCRideStateMachineFactory : NSObject

+ (TKStateMachine *) createOnDemandStateMachine;
+ (TKStateMachine *) createOnDemandStateMachineWithState:(TKState *) initialState;


@end
