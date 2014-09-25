//
//  Ride.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Ticket.h"
#import "Car.h"
#import "Driver.h"
#import "Fare.h"
#import <RKPathMatcher.h>
#import "VCApi.h"
#import "VCPushApi.h"

@interface Ticket ()


@end

@implementation Ticket

@dynamic rideType;
@dynamic car_id;
@dynamic driver_id;
@dynamic ride_id;
@dynamic requestedTimestamp;
@dynamic estimatedArrivalTime;
@dynamic originLatitude;
@dynamic originLongitude;
@dynamic originPlaceName;
@dynamic destinationLatitude;
@dynamic destinationLongitude;
@dynamic destinationPlaceName;
@dynamic uploaded;
@dynamic driver;
@dynamic car;
@dynamic rideDate;
@dynamic originShortName;
@dynamic destinationShortName;
@dynamic confirmed;
@dynamic driving;
@dynamic trip_id;
@dynamic meetingPointLatitude;
@dynamic meetingPointLongitude;
@dynamic meetingPointPlaceName;
@dynamic dropOffPointLatitude;
@dynamic dropOffPointLongitude;
@dynamic dropOffPointPlaceName;
@dynamic hovFare;
@dynamic fixedPrice;
@dynamic direction;
@dynamic returnTicketFetchRequest;

+ (void)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Ticket"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"ride_id" : @"ride_id",
                                                        @"fare_id" : @"fare_id",
                                                        @"state" : @"forcedState",
                                                        @"meeting_point_place_name" : @"meetingPointPlaceName",
                                                        @"meeting_point_latitude" : @"meetingPointLatitude",
                                                        @"meeting_point_longitude" : @"meetingPointLongitude",
                                                        @"drop_off_point_place_name" : @"dropOffPointPlaceName",
                                                        @"drop_off_point_latitude" : @"dropOffPointLatitude",
                                                        @"drop_off_point_longitude" : @"dropOffPointLongitude",
                                                        @"origin_place_name" : @"originPlaceName",
                                                        @"origin_latitude" : @"originLatitude",
                                                        @"origin_longitude" : @"originLongitude",
                                                        @"origin_short_name" : @"originShortName",
                                                        @"destination_place_name" : @"destinationPlaceName",
                                                        @"destination_latitude" : @"destinationLatitude",
                                                        @"destination_longitude" : @"destinationLongitude",
                                                        @"destination_short_name" : @"destinationShortName",
                                                        @"driving" : @"driving",
                                                        @"trip_id" : @"trip_id",
                                                        @"pickup_time" : @"pickupTime",
                                                        @"fixed_price" : @"fixedPrice",
                                                        @"direction" : @"direction"
                                                        }];
    
    entityMapping.identificationAttributes = @[ @"ride_id" ]; // for riders ride_id is the primary key

    /*
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_GET_ACTIVE_TICKETS];
        
        NSString * relativePath = [URL relativePath];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:relativePath tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
            return fetchRequest;
        }
        
        return nil;
    }];
     */
    
     
    
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"driver" mapping:[Driver createMappings:objectManager]];
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"car" mapping:[Car createMappings:objectManager]];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_ACTIVE_TICKETS
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
}


+ (Ticket *) ticketWithFareId: (NSNumber *) fareId{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Ticket"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fare_id = %@", fareId];
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

- (NSString *) routeDescription {
    return [NSString stringWithFormat:@"%@ to %@", self.originPlaceName, self.destinationPlaceName];
}

- (NSString *) shortRouteDescription {
    return [NSString stringWithFormat:@"%@ to %@", self.originShortName, self.destinationShortName];
}

- (CLLocation *) originLocation {
    return [[CLLocation alloc] initWithLatitude:[self.originLatitude doubleValue] longitude: [self.originLongitude doubleValue] ];
}

- (CLLocation *) destinationLocation {
    return [[CLLocation alloc] initWithLatitude:[self.destinationLatitude doubleValue] longitude: [self.destinationLongitude doubleValue] ];
}

- (CLLocation *) meetingPointLocation {
    return [[CLLocation alloc] initWithLatitude:[self.meetingPointLatitude doubleValue] longitude: [self.meetingPointLongitude doubleValue] ];
}

- (CLLocation *) dropOffPointLocation {
    return [[CLLocation alloc] initWithLatitude:[self.dropOffPointLatitude doubleValue] longitude: [self.dropOffPointLongitude doubleValue] ];
}

// For the state machine, currently unused
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

- (Ticket *) returnTicket {
    NSArray * returnTicketResults = self.returnTicketFetchRequest;
    if(returnTicketResults == nil || [returnTicketResults count] < 1){
        return nil;
    } else {
        return returnTicketResults[0];
    }
}




+ (NSArray * ) ticketsForTrip:(NSNumber *) tripId {
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"trip_id = %@", tripId];
    [fetch setPredicate:predicate];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"pickupTime" ascending:YES];
    [fetch setSortDescriptors:@[sort]];
    NSError * error;
    NSArray * ticketsForTrip = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
    if(ticketsForTrip == nil){
        [WRUtilities criticalError:error];
        return nil;
    }
    return ticketsForTrip;

}








@end
