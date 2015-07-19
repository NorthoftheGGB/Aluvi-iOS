//
//  VCTransport.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

@interface Transit :  NSManagedObject

@property (nonatomic, retain) NSNumber * fare_id;
@property (nonatomic, retain) NSNumber * meetingPointLatitude;
@property (nonatomic, retain) NSNumber * meetingPointLongitude;
@property (nonatomic, retain) NSString * meetingPointPlaceName;
@property (nonatomic, retain) NSNumber * dropOffPointLongitude;
@property (nonatomic, retain) NSNumber * dropOffPointLatitude;
@property (nonatomic, retain) NSString * dropOffPointPlaceName;
@property (nonatomic, retain) NSDate * desiredArrival;
@property (nonatomic, retain) NSDate * pickupTime;
@property (nonatomic, retain) NSString * state;

- (NSString *) routeDescription;

@end
