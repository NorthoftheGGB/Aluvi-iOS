//
//  VCTransport.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCStateMachineManagedObject.h"

@interface Transit :  NSManagedObject  // VCStateMachineManagedObject
// Original implementation extended VCStateMachineManagedObject but using a state machine in the mobile app
// as well as on the server has been problematic.  For the moment the mobile app state is slaved to the server


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

// state management copied from VCStateMachineManagedObject
@property (nonatomic, weak) NSString * forcedState;
@property (nonatomic, retain) NSString * savedState;
- (void) setForcedState: (NSString*) state__;
- (NSString *) forcedState;
- (NSString *) state;

@end
