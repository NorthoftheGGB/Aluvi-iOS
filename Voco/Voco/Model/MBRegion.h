//
//  MBRegion.h
//  Voco
//
//  Created by Thomas DiZoglio on 7/27/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/Mapkit.h>

@interface MBRegion : NSObject <NSCoding>

@property (nonatomic) CLLocationCoordinate2D topLocation;
@property (nonatomic) CLLocationCoordinate2D bottomLocation;

- (void)initWithTopCoordinate:(CLLocationCoordinate2D)top bottomCoordinate:(CLLocationCoordinate2D)bottom;

@end
