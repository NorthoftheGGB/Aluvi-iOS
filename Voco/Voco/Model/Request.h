//
//  Ride.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VCRestKitMappableObject.h"
#import <TransitionKit.h>
#import "Trip.h"

#define RIDE_REQUEST_TYPE_ON_DEMAND @"on_demand"
#define RIDE_REQUEST_TYPE_COMMUTER @"commuter"

#define kCreatedState @"created"
#define kRequestedState @"requested"
#define kDeclinedState @"declined"
#define kFoundState @"found"
#define kScheduledState @"scheduled"
#define kDriverCancelledState @"driver_cancelled"
#define kRiderCancelledState @"rider_cancelled"
#define kCompleteState @"complete"
#define kPaymentProblemState @"payment_problem"

#define kEventRideCancelledByRider @"ride_canceled_by_rider"
#define kEventRideRequested @"ride_requested"
#define kEventRideFound @"ride_found"
#define kEventRideScheduled @"ride_scheduled"
#define kEventRideDeclined @"ride_declined"
#define kEventRideCancelledByDriver @"ride_cancelled_by_driver"
#define kEventPaymentProcessedSuccessfully @"payment_processed_successfully"
#define kEventPaymentFailed @"payment_failed"

@class Car, Driver;

@interface Request : Trip <VCRestKitMappableObject>

@property (nonatomic, retain) NSString * requestType;
@property (nonatomic, retain) NSNumber * car_id;
@property (nonatomic, retain) NSNumber * driver_id;
@property (nonatomic, retain) NSDate * requestedTimestamp;
@property (nonatomic, retain) NSDate * estimatedArrivalTime;
@property (nonatomic, retain) NSNumber * originLatitude;
@property (nonatomic, retain) NSNumber * originLongitude;
@property (nonatomic, retain) NSString * originPlaceName;

@property (nonatomic, retain) NSNumber * request_id;



@property (nonatomic, retain) Driver *driver;
@property (nonatomic, retain) Car *car;


+ (Request *) rideWithId: (NSNumber *) rideId;

@end
