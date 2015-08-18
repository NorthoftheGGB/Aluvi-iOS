//
//  Ride.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Ticket.h"
#import <RKPathMatcher.h>
#import "Car.h"
#import "Driver.h"
#import "Rider.h"
#import "Payment.h"
#import "Earning.h"
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
@dynamic trip_state;
@dynamic meetingPointLatitude;
@dynamic meetingPointLongitude;
@dynamic meetingPointPlaceName;
@dynamic dropOffPointLatitude;
@dynamic dropOffPointLongitude;
@dynamic dropOffPointPlaceName;
@dynamic fixedPrice;
@dynamic direction;
@dynamic returnTicketFetchRequest;
@dynamic riders;
@dynamic payment;
@dynamic earning;
@dynamic estimatedEarnings;

@synthesize polyline;
@synthesize region;

+ (RKEntityMapping * )createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Ticket"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"ride_id" : @"ride_id",
                                                        @"fare_id" : @"fare_id",
                                                        @"state" : @"state",
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
                                                        @"trip_state" : @"trip_state",
                                                        @"pickup_time" : @"pickupTime",
                                                        @"fixed_price" : @"fixedPrice",
                                                        @"direction" : @"direction"
                                                        }];
    
    entityMapping.identificationAttributes = @[ @"ride_id" ]; // for riders ride_id is the primary key
    
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"driver" mapping:[Driver createMappings:objectManager]];
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"car" mapping:[Car createMappings:objectManager]];
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"riders" mapping:[Rider createMappings:objectManager]];
    
      
    return entityMapping;
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

- (CLLocationCoordinate2D) meetingPointCoordinate {
    return CLLocationCoordinate2DMake([self.meetingPointLatitude doubleValue], [self.meetingPointLongitude doubleValue]);
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

- (BOOL) hasCachedRoute {
    if(self.polyline != nil && self.region != nil && [self.polyline count] > 0){
        return TRUE;
    } else {
        return FALSE;
    }
}








@end
