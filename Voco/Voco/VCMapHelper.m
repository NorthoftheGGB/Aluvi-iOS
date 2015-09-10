//
//  VCMapHelper.m
//  Voco
//
//  Created by matthewxi on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCMapHelper.h"

#define kMapPadding .05

@implementation VCMapHelper

+ (CLLocationCoordinate2D) paddedNELocation:(CLLocationCoordinate2D) location {
    CLLocationCoordinate2D l;
    l.latitude = location.latitude - kMapPadding;
    l.longitude = location.longitude - kMapPadding;
    return l;
}

+ (CLLocationCoordinate2D) paddedSWLocation:(CLLocationCoordinate2D) location {
    CLLocationCoordinate2D l;
    l.latitude = location.latitude + kMapPadding;
    l.longitude = location.longitude + kMapPadding;
    return l;
}
+ (BOOL) validCoordinate: (CLLocationCoordinate2D) location {
    if(location.latitude != 0 && location.longitude != 0) {
        return YES;
    } else {
        return NO;
    }
}



@end
