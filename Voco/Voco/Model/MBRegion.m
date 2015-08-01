//
//  MBRegion.m
//  Voco
//
//  Created by Thomas DiZoglio on 7/27/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "MBRegion.h"

@implementation MBRegion

- (void)initWithTopCoordinate:(CLLocationCoordinate2D)top bottomCoordinate:(CLLocationCoordinate2D)bottom {

    _topLocation = top;
    _bottomLocation = bottom;
}

@end