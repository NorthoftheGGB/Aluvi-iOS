//
//  Ticket.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@import MapKit;
#import "Transit.h"
#import "MBRegion.h"

// State
#define kCreatedState @"created"
#define kRequestedState @"requested"
#define kScheduledState @"scheduled"
#define kInProgressState @"started"
#define kCommuteSchedulerFailedState @"commute_scheduler_failed"
#define kDriverCancelledState @"driver_cancelled"
#define kRiderCancelledState @"rider_cancelled"
#define kCompleteState @"complete"
#define kPaymentProblemState @"payment_problem"

// Trip State
#define kTripRequestedState @"requested"
#define kTripFulfilledState @"fulfilled"
#define kTripUnfulfilledState @"unfulfilled"
#define kTripAbortedState @"aborted"
#define kTripRescindedState @"rescinded"


#define kRideRequestTypeCommuter @"commuter"


@class Car, Driver, Rider, Payment, Earning;

@interface Ticket : Transit 
@property (nonatomic, retain) NSNumber * ride_id;
@property (nonatomic, retain) NSString * rideType;
@property (nonatomic, retain) NSNumber * car_id;
@property (nonatomic, retain) NSNumber * driver_id;
@property (nonatomic, retain) NSDate * requestedTimestamp;
@property (nonatomic, retain) NSDate * estimatedArrivalTime;
@property (nonatomic, retain) NSNumber * originLatitude;
@property (nonatomic, retain) NSNumber * originLongitude;
@property (nonatomic, retain) NSString * originPlaceName;
@property (nonatomic, retain) NSString * originShortName;
@property (nonatomic, retain) NSNumber * destinationLatitude;
@property (nonatomic, retain) NSNumber * destinationLongitude;
@property (nonatomic, retain) NSString * destinationPlaceName;
@property (nonatomic, retain) NSString * destinationShortName;
@property (nonatomic, retain) NSNumber * meetingPointLatitude;
@property (nonatomic, retain) NSNumber * meetingPointLongitude;
@property (nonatomic, retain) NSString * meetingPointPlaceName;
@property (nonatomic, retain) NSNumber * dropOffPointLatitude;
@property (nonatomic, retain) NSNumber * dropOffPointLongitude;
@property (nonatomic, retain) NSString * dropOffPointPlaceName;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) NSDate * rideDate;
@property (nonatomic, retain) NSNumber * confirmed;
@property (nonatomic, retain) NSNumber * driving;
@property (nonatomic, retain) NSNumber * trip_id;
@property (nonatomic, retain) NSString * trip_state;
@property (nonatomic, retain) NSNumber * fixedPrice;
@property (nonatomic, retain) NSNumber * estimatedEarnings;
@property (nonatomic, retain) NSString * direction;

@property (nonatomic, retain) Payment *payment;
@property (nonatomic, retain) Earning *earning;
@property (nonatomic, retain) Driver *driver;
@property (nonatomic, retain) Car *car;
@property (nonatomic, retain) NSSet *riders;


@property (nonatomic, retain) NSArray * returnTicketFetchRequest;

// Map Route Caching
@property (nonatomic, strong) NSArray * polyline;   // TODO needs to be coded to data using NSKeyedArchiver
@property (nonatomic, strong) MBRegion * region;    // TODO needs to be coded to data using NSKeyedArchiver

+ (Ticket *) ticketWithFareId: (NSNumber *) fareId;

+ (void)createMappings:(RKObjectManager *)objectManager;

+ (NSArray * ) ticketsForTrip:(NSNumber *) tripId;

- (Ticket *) returnTicket;

- (CLLocation *) originLocation;
- (CLLocation *) destinationLocation;
- (CLLocation *) meetingPointLocation;
- (CLLocation *) dropOffPointLocation;

- (NSString *) shortRouteDescription;
- (NSString *) routeDescription;
- (BOOL) hasCachedRoute;

@end

@interface Ticket (CoreDataGeneratedAccessors)

- (void)addRidesObject:(Rider *)value;
- (void)removeRidersObject:(Rider *)value;
- (void)addRiders:(NSSet *)values;
- (void)removeRiders:(NSSet *)values;

@end
