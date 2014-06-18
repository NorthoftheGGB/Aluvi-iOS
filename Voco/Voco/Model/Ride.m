//
//  Ride.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Ride.h"
#import <TransitionKit.h>
#import "VCRideStateMachineFactory.h"

@interface Ride ()

@property (nonatomic, strong) TKStateMachine * stateMachine;

@end

@implementation Ride

@dynamic ride_id;
@dynamic requestType;
@dynamic car_id;
@dynamic driver_id;
@dynamic state;
@dynamic request_id;
@dynamic requestedTimestamp;
@dynamic estimatedArrivalTime;
@dynamic originLatitude;
@dynamic originLongitude;
@dynamic meetingPointLatitude;
@dynamic meetingPointLongitude;
@dynamic destinationLongitude;
@dynamic destinationLatitude;

@synthesize stateMachine = _stateMachine;

+ (void)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Ride"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"request_id" : @"request_id",
                                                        @"id" : @"ride_id",
                                                        @"meeting_point_place_name" : @"meetingPointPlaceName",
                                                        @"meeting_point_latitude" : @"meetingPointLattitude",
                                                        @"meeting_point_longitude" : @"meetingPointLongitude",
                                                        @"destination_place_name" : @"destinationPlaceName"}];

    entityMapping.identificationAttributes = @[ @"request_id" ]; // for riders request_id is the primary key
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_SCHEDULED_RIDES_PATH_PATTERN
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
}



- (id) init{
    self = [super init];
    if(self != nil){

    }
    return self;
}

- (void)awakeFromFetch {
    _stateMachine = [VCRideStateMachineFactory createOnDemandStateMachineWithState:self.state];
}

- (void)willSave {
    if(self.state != _stateMachine.currentState.name ){
        self.state = _stateMachine.currentState.name;
    }
}

@end
