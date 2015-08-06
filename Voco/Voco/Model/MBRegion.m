//
//  MBRegion.m
//  Voco
//
//  Created by Thomas DiZoglio on 7/27/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "MBRegion.h"

@implementation MBRegion

NSString *const kTopCoordinateLatitudeKey = @"kTopCoordinateLatitudeKey";
NSString *const kTopCoordinateLongitudeKey = @"kTopCoordinateLongitudeKey";
NSString *const kBottomCoordinateLatitudeKey = @"kBottomCoordinateLatitudeKey";
NSString *const kBottomCoordinateLongitudeKey = @"kBottomCoordinateLongitudeKey";

- (void)initWithTopCoordinate:(CLLocationCoordinate2D)top bottomCoordinate:(CLLocationCoordinate2D)bottom {

    _topLocation = top;
    _bottomLocation = bottom;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        
        CLLocationDegrees topLatitude = [decoder decodeDoubleForKey:kTopCoordinateLatitudeKey];
        CLLocationDegrees topLongitude = [decoder decodeDoubleForKey:kTopCoordinateLongitudeKey];
        _topLocation = CLLocationCoordinate2DMake(topLatitude, topLongitude);

        CLLocationDegrees bottomLatitude = [decoder decodeDoubleForKey:kBottomCoordinateLatitudeKey];
        CLLocationDegrees bottomLongitude = [decoder decodeDoubleForKey:kBottomCoordinateLongitudeKey];
        _bottomLocation = CLLocationCoordinate2DMake(bottomLatitude, bottomLongitude);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {

    [encoder encodeDouble:_topLocation.latitude forKey:kTopCoordinateLatitudeKey];
    [encoder encodeDouble:_topLocation.longitude forKey:kTopCoordinateLongitudeKey];

    [encoder encodeDouble:_bottomLocation.latitude forKey:kBottomCoordinateLatitudeKey];
    [encoder encodeDouble:_bottomLocation.longitude forKey:kBottomCoordinateLongitudeKey];
}

@end
