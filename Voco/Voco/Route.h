//
//  Route.h
//  Voco
//
//  Created by Matthew Shultz on 10/26/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBRegion.h"
@import CoreLocation;

@interface Route : NSObject <NSCopying>

@property (nonatomic, strong) CLLocation * home;
@property (nonatomic, strong) CLLocation * work;
@property (nonatomic, strong) NSString * homePlaceName;
@property (nonatomic, strong) NSString * workPlaceName;
@property (nonatomic, strong) NSString * pickupTime;
@property (nonatomic, strong) NSString * returnTime;
@property (nonatomic) BOOL driving;
@property (nonatomic) NSArray * polyline;   // TODO needs to be coded to data using NSKeyedArchiver
@property (nonatomic) MBRegion * region;    // TODO needs to be coded to data using NSKeyedArchiver


+ (RKObjectMapping *) getMapping;
+ (RKObjectMapping *) getInverseMapping;

- (BOOL) routeCoordinateSettingsValid;
- (BOOL) hasCachedPath;
- (void) clearCachedPath;

- (BOOL) coordinatesDifferFrom: (Route*) route;
- (void) copyNonCoordinateFieldsFrom: (Route*) route;


@end
