//
//  VCMapHelper.h
//  Voco
//
//  Created by matthewxi on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/Mapkit.h>

@interface VCMapHelper : NSObject

+ (CLLocationCoordinate2D) paddedNELocation:(CLLocationCoordinate2D) location;
+ (CLLocationCoordinate2D) paddedSWLocation:(CLLocationCoordinate2D) location;

@end
