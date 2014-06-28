//
//  VCStateMachineManagedObject.h
//  Voco
//
//  Created by Matthew Shultz on 6/26/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <TransitionKit.h>

@interface VCStateMachineManagedObject : NSManagedObject

@property (nonatomic, weak) NSString * forcedState;


- (BOOL)canFireEvent:(id)eventOrEventName;
- (BOOL)fireEvent:(id)eventOrEventName userInfo:(NSDictionary *)userInfo error:(NSError **)error;

- (void) assignStatesAndEvents:(TKStateMachine *) stateMachine;
- (NSString *) getInitialState;

- (NSString *) state; 


@end
