//
//  Transport.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Fare.h"
#import "VCApi.h"
#import "Rider.h"

@interface Fare ()

@end

@implementation Fare

@dynamic car_id;
@dynamic ticket;
@dynamic riders;
@dynamic driveTime;
@dynamic distance;
@dynamic estimatedEarnings;

- (id) init{
    self = [super init];
    if(self != nil){
        
    }
    return self;
}


+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Fare"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"fare_id",
                                                        @"state" : @"state",
                                                        @"meeting_point_place_name" : @"meetingPointPlaceName",
                                                        @"meeting_point_latitude" : @"meetingPointLatitude",
                                                        @"meeting_point_longitude" : @"meetingPointLongitude",
                                                        @"drop_off_point_place_name" : @"dropOffPointPlaceName",
                                                        @"drop_off_point_latitude" : @"dropOffPointLatitude",
                                                        @"drop_off_point_longitude" : @"dropOffPointLongitude",
                                                        @"pickup_time" : @"pickupTime",
                                                        @"drive_time" : @"driveTime",
                                                        @"distance" : @"distance",
                                                        @"estimated_earnings" : @"estimatedEarnings"
                                                        }];
    
    
    entityMapping.identificationAttributes = @[ @"fare_id" ];
    
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"riders" mapping:[Rider createMappings:objectManager]];
    [entityMapping addConnectionForRelationship:@"ticket" connectedBy:@{@"fare_id" : @"fare_id"}];

    
    {
        RKResponseDescriptor * responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                     method:RKRequestMethodGET
                                                pathPattern:API_GET_DRIVER_FARE_PATH_PATTERN
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKResponseDescriptor * responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                     method:RKRequestMethodGET
                                                pathPattern:API_GET_ACTIVE_FARES
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    return entityMapping;
}

- (void)createMappings:(RKObjectManager *)objectManager{
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
                                                        @"pickup_time" : @"pickupTime"
                                                        }];
    
    entityMapping.identificationAttributes = @[ @"ride_id" ]; // for riders ride_id is the primary key
    
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_ACTIVE_TICKETS
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
}


- (NSString *) routeDescription {
    return [NSString stringWithFormat:@"%@ to %@", self.meetingPointPlaceName, self.dropOffPointPlaceName];
}
@end
