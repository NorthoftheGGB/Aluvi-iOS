//
//  VCTransport.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Transit.h"

@implementation Transit
@dynamic ride_id;
@dynamic meetingPointLatitude;
@dynamic meetingPointLongitude;
@dynamic meetingPointPlaceName;
@dynamic dropOffPointLongitude;
@dynamic dropOffPointLatitude;
@dynamic dropOffPointPlaceName;
@dynamic desiredArrival;
@dynamic pickupTime;

- (NSString *) routeDescription {
    return [NSString stringWithFormat:@"%@ to %@", self.meetingPointPlaceName, self.dropOffPointPlaceName];
}

@end
