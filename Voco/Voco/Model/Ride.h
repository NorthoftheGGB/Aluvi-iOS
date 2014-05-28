//
//  Ride.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Ride : NSManagedObject

@property (nonatomic, retain) NSNumber * ride_id;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * car_id;
@property (nonatomic, retain) NSNumber * driver_id;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSDate * requested_timestamp;
@property (nonatomic, retain) NSDate * estimated_arrival_time;
@property (nonatomic, retain) NSDecimalNumber * origin_latitude;
@property (nonatomic, retain) NSDecimalNumber * origin_longitude;
@property (nonatomic, retain) NSDecimalNumber * meeting_point_latitude;
@property (nonatomic, retain) NSDecimalNumber * meeting_point_longitude;
@property (nonatomic, retain) NSDecimalNumber * destination_longitude;
@property (nonatomic, retain) NSDecimalNumber * destination_latitude;
@property (nonatomic, retain) NSNumber * request_id;


@end
