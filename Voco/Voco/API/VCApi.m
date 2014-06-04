//
//  VCApi.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCApi.h"

@implementation VCApi

+ (NSString *) devicesObjectPathPattern {
    return [NSString stringWithFormat:@"%@:uuid", API_DEVICES];
}

+ (NSString *) getRideOffersPath:(NSNumber*) driverId {
    return [NSString stringWithFormat:@"%@%@", API_GET_RIDE_OFFERS, driverId];
}

+ (NSString *) getScheduledRidesPath:(NSNumber*) riderId {
    return [NSString stringWithFormat:@"%@%@", API_GET_SCHEDULED_RIDES, riderId];
}

+ (NSString *) getPutGeoCarPath:(NSNumber *) carId {
    return [NSString stringWithFormat:@"%@%@", API_GEO_CAR, carId];
}

@end
