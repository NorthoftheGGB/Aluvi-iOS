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

#define RIDE_REQUEST_TYPE_ON_DEMAND @"on_demand"
#define RIDE_REQUEST_TYPE_COMMUTER @"commuter"

@interface Ride : NSManagedObject <VCRestKitMappableObject>

@property (nonatomic, retain) NSNumber * ride_id;
@property (nonatomic, retain) NSString * requestType;
@property (nonatomic, retain) NSNumber * car_id;
@property (nonatomic, retain) NSNumber * driver_id;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSDate * requestedTimestamp;
@property (nonatomic, retain) NSDate * estimatedArrivalTime;
@property (nonatomic, retain) NSNumber * originLatitude;
@property (nonatomic, retain) NSNumber * originLongitude;
@property (nonatomic, retain) NSNumber * meetingPointLatitude;
@property (nonatomic, retain) NSNumber * meetingPointLongitude;
@property (nonatomic, retain) NSNumber * destinationLongitude;
@property (nonatomic, retain) NSNumber * destinationLatitude;
@property (nonatomic, retain) NSNumber * request_id;


@end
