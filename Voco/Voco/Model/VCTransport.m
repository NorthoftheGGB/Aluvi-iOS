//
//  VCTransport.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTransport.h"

@implementation VCTransport
@dynamic ride_id;
@dynamic meetingPointLatitude;
@dynamic meetingPointLongitude;
@dynamic meetingPointPlaceName;
@dynamic destinationLongitude;
@dynamic destinationLatitude;
@dynamic destinationPlaceName;
@dynamic desiredArrival;



- (NSString *) routeDescription {
    return [NSString stringWithFormat:@"%@ to %@", self.meetingPointPlaceName, self.destinationPlaceName];
}

@end
