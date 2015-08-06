//
//  MBRegion.m
//  Voco
//
//  Created by Thomas DiZoglio on 7/27/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "MBRegion.h"

#define kNELat @"NELat"
#define kNELong @"NELong"
#define kSWLat @"SWLat"
#define kSWLon @"SWLon"

@implementation MBRegion

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if(self != nil) {
        CLLocationCoordinate2D northEast, southWest;
        northEast.latitude = [decoder decodeDoubleForKey:kNELat];
        northEast.longitude = [decoder decodeDoubleForKey:kNELong];
        southWest.latitude = [decoder decodeDoubleForKey:kSWLat];
        southWest.longitude = [decoder decodeDoubleForKey:kSWLon];

        [self initWithSouthWest:southWest northEast:northEast];
    }
    return self;
    
}

- (void)initWithSouthWest:(CLLocationCoordinate2D)southWest northEast:(CLLocationCoordinate2D)northEast {
    _southWest = southWest;
    _northEast = northEast;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBRegion * copy = [[MBRegion alloc] init];
    if(copy){
        copy.northEast = self.northEast;
        copy.southWest = self.southWest;
    }
    return copy;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:_northEast.latitude forKey:kNELat ];
    [encoder encodeDouble:_northEast.longitude forKey:kNELong ];
    [encoder encodeDouble:_southWest.latitude forKey:kSWLat ];
    [encoder encodeDouble:_southWest.longitude forKey:kSWLon ];
}

- (BOOL) isValidRegion {
    if( fabs(_northEast.latitude) <= .000001 || fabs(_northEast.latitude) <= .000001
       || fabs(_southWest.longitude) <= .000001 || fabs(_southWest.longitude) <= .000001 ){
        return NO;
    } else {
        return YES;
    }
}





@end
