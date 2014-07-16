//
//  VCTransport.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCStateMachineManagedObject.h"

@interface Transit : VCStateMachineManagedObject

@property (nonatomic, retain) NSNumber * ride_id;
@property (nonatomic, retain) NSNumber * meetingPointLatitude;
@property (nonatomic, retain) NSNumber * meetingPointLongitude;
@property (nonatomic, retain) NSString * meetingPointPlaceName;
@property (nonatomic, retain) NSNumber * dropOffPointLongitude;
@property (nonatomic, retain) NSNumber * dropOffPointLatitude;
@property (nonatomic, retain) NSString * dropOffPointPlaceName;
@property (nonatomic, retain) NSDate * desiredArrival;
@property (nonatomic, retain) NSDate * pickupTime;

- (NSString *) routeDescription;

@end
