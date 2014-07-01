//
//  VCTransport.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCStateMachineManagedObject.h"

@interface VCTransport : VCStateMachineManagedObject

@property (nonatomic, retain) NSNumber * ride_id;
@property (nonatomic, retain) NSNumber * meetingPointLatitude;
@property (nonatomic, retain) NSNumber * meetingPointLongitude;
@property (nonatomic, retain) NSString * meetingPointPlaceName;
@property (nonatomic, retain) NSNumber * destinationLongitude;
@property (nonatomic, retain) NSNumber * destinationLatitude;
@property (nonatomic, retain) NSString * destinationPlaceName;
@property (nonatomic, retain) NSDate * desiredArrival;

@end
