//
//  MBRegion.h
//  Voco
//
//  Created by Thomas DiZoglio on 7/27/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/Mapkit.h>

@interface MBRegion : NSObject <NSCopying, NSCoding>

@property (nonatomic) CLLocationCoordinate2D northEast;
@property (nonatomic) CLLocationCoordinate2D southWest;

- (void) initWithSouthWest:(CLLocationCoordinate2D)southWest northEast:(CLLocationCoordinate2D)northEast;
- (BOOL) isValidRegion;

@end
