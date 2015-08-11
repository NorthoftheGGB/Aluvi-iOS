//
//  MBRegion.m
//  Voco
//
//  Created by Thomas DiZoglio on 7/27/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "MBRegion.h"

#define kTopKeyLat @"TopKeyLat"
#define kTopKeyLong @"TopKeyLong"
#define kBottomKeyLat @"BottomKeyLat"
#define kBottomKeyLon @"BottomKeyLon"

@implementation MBRegion

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if(self != nil) {
        CLLocationCoordinate2D top, bottom;
        top.latitude = [decoder decodeDoubleForKey:kTopKeyLat];
        top.longitude = [decoder decodeDoubleForKey:kTopKeyLong];
        top.latitude = [decoder decodeDoubleForKey:kBottomKeyLat];
        top.longitude = [decoder decodeDoubleForKey:kBottomKeyLon];

        [self initWithTopCoordinate:top bottomCoordinate:bottom];
    }
    return self;
    
}

- (void)initWithTopCoordinate:(CLLocationCoordinate2D)top bottomCoordinate:(CLLocationCoordinate2D)bottom {

    _topLocation = top;
    _bottomLocation = bottom;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBRegion * copy = [[MBRegion alloc] init];
    if(copy){
        copy.topLocation = self.topLocation;
        copy.bottomLocation = self.bottomLocation;
    }
    return copy;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:_topLocation.latitude forKey:kTopKeyLat ];
    [encoder encodeDouble:_topLocation.longitude forKey:kTopKeyLong ];
    [encoder encodeDouble:_bottomLocation.latitude forKey:kBottomKeyLat ];
    [encoder encodeDouble:_bottomLocation.longitude forKey:kBottomKeyLon ];
}

- (BOOL) isValidRegion {
    if( fabs(self.topLocation.latitude) <= .000001 || fabs(self.bottomLocation.latitude) <= .000001
       || fabs(self.topLocation.longitude) <= .000001 || fabs(self.bottomLocation.longitude) <= .000001 ){
        return NO;
    } else {
        return YES;
    }
}





@end
