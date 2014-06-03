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


@end
