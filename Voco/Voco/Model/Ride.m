//
//  Ride.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Ride.h"
#import "Car.h"
#import "Driver.h"
#import <RKPathMatcher.h>

@interface Ride ()


@end

@implementation Ride

@dynamic ride_id;
@dynamic requestType;
@dynamic car_id;
@dynamic driver_id;
@dynamic request_id;
@dynamic requestedTimestamp;
@dynamic estimatedArrivalTime;
@dynamic originLatitude;
@dynamic originLongitude;
@dynamic originPlaceName;
@dynamic meetingPointLatitude;
@dynamic meetingPointLongitude;
@dynamic meetingPointPlaceName;
@dynamic destinationLongitude;
@dynamic destinationLatitude;
@dynamic destinationPlaceName;
@dynamic driver;
@dynamic car;
@dynamic desiredArrival;


+ (void)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Ride"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"request_id" : @"request_id",
                                                        @"id" : @"ride_id",
                                                        @"state" : @"forcedState",
                                                        @"meeting_point_place_name" : @"meetingPointPlaceName",
                                                        @"meeting_point_latitude" : @"meetingPointLattitude",
                                                        @"meeting_point_longitude" : @"meetingPointLongitude",
                                                        @"destination_place_name" : @"destinationPlaceName",
                                                        @"destination_latitude" : @"destinationLatitude",
                                                        @"destination_longitude" : @"destinationLongitude",
                                                        }];
    

    entityMapping.identificationAttributes = @[ @"request_id" ]; // for riders request_id is the primary key

    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_GET_SCHEDULED_RIDES];
        
        NSString * relativePath = [URL relativePath];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:relativePath tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ride"];
            return fetchRequest;
        }
        
        return nil;
    }];
     
    
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"driver" mapping:[Driver createMappings:objectManager]];
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"car" mapping:[Car createMappings:objectManager]];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_SCHEDULED_RIDES
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
}


+ (Ride *) rideWithId: (NSNumber *) rideId{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Ride"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ride_id = %@", rideId];
    [request setPredicate:predicate];
    NSError * error;
    NSArray * rides = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
    if(rides == nil){
        [WRUtilities criticalError:error];
        return nil;
    }
    return [rides objectAtIndex:0];
}


- (id) init{
    self = [super init];
    if(self != nil){

    }
    return self;
}

- (void)assignStatesAndEvents:(TKStateMachine *)stateMachine {
    
    TKState * created = [TKState stateWithName:kCreatedState];
    TKState * requested = [TKState stateWithName:kRequestedState];
    TKState * declined = [TKState stateWithName:kDeclinedState];
    TKState * found = [TKState stateWithName:kFoundState];
    TKState * scheduled = [TKState stateWithName:kScheduledState];
    TKState * driverCancelled = [TKState stateWithName:kDriverCancelledState];
    TKState * riderCancelled = [TKState stateWithName:kRiderCancelledState];
    TKState * complete = [TKState stateWithName:kCompleteState];
    TKState * paymentProblem = [TKState stateWithName:kPaymentProblemState];
    
    TKEvent * rideRequested = [TKEvent eventWithName:kEventRideRequested transitioningFromStates:@[created] toState:requested];
    TKEvent * rideCancelledByRider = [TKEvent eventWithName:kEventRideCancelledByRider transitioningFromStates:@[requested, found, scheduled] toState:riderCancelled];
    TKEvent * rideFound = [TKEvent eventWithName:kEventRideFound transitioningFromStates:@[requested] toState:found];
    TKEvent * rideScheduled = [TKEvent eventWithName:kEventRideScheduled transitioningFromStates:@[found] toState:scheduled];
    TKEvent * rideDeclined = [TKEvent eventWithName:kEventRideDeclined transitioningFromStates:@[created, requested] toState:declined];
    TKEvent * rideCancelledByDriver = [TKEvent eventWithName:kEventRideCancelledByDriver transitioningFromStates:@[scheduled] toState:driverCancelled];
    TKEvent * paymentProcessedSuccessfully = [TKEvent eventWithName:kEventPaymentProcessedSuccessfully transitioningFromStates:@[scheduled] toState:complete];
    TKEvent * paymentFailure = [TKEvent eventWithName:kEventPaymentFailed transitioningFromStates:@[scheduled] toState:paymentProblem];

    
    [stateMachine addStates:@[created, requested, declined, found, scheduled, driverCancelled, riderCancelled, complete, paymentProblem]];
    [stateMachine addEvents:@[rideRequested, rideCancelledByRider, rideFound, rideScheduled, rideDeclined, rideCancelledByDriver, paymentProcessedSuccessfully, paymentFailure]];
}

- (NSString *)getInitialState {
    return kCreatedState;
}



- (NSString *) routeDescription {
    return [NSString stringWithFormat:@"%@ to %@", self.originPlaceName, self.destinationPlaceName];
}






@end
