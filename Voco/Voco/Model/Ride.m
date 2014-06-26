//
//  Ride.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Ride.h"
#import "VCRideStateMachineFactory.h"
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


@synthesize stateMachine = _stateMachine;
@synthesize forcedState;

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
                                                        @"destination_longitude" : @"destinationLongitude"
                                                        }];
    

    entityMapping.identificationAttributes = @[ @"request_id" ]; // for riders request_id is the primary key

    /*
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
     */
    
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

- (void)awakeFromInsert {
    _stateMachine = [VCRideStateMachineFactory createOnDemandStateMachine];
}

- (void)awakeFromFetch {
    _stateMachine = [VCRideStateMachineFactory createOnDemandStateMachineWithState:self.savedState];
}

- (void)willSave {
    if(! [self.savedState isEqualToString: _stateMachine.currentState.name] ){
        self.savedState = _stateMachine.currentState.name;
    }
}

- (NSString *) routeDescription {
    return [NSString stringWithFormat:@"%@ to %@", self.meetingPointPlaceName, self.destinationPlaceName];
}


- (NSString *) state {
    NSString * state = [_stateMachine.currentState name];
    return state;
}

// Manually set the state, for restkit
- (void) setForcedState: (NSString*) state__ {
   // self.savedState = state__;
    _stateMachine = [VCRideStateMachineFactory createOnDemandStateMachineWithState:state__];

}




@end
