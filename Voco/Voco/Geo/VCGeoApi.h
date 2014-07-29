//
//  VCGeoApi.h
//  Voco
//
//  Created by Matthew Shultz on 7/4/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "VCGeoObject.h"
#import "VCDriverGeoObject.h"

@interface VCGeoApi : NSObject

+ (void) setup: (RKObjectManager *) objectManager;

+ (void) sendDriverLocation: (CLLocation *) location
                    success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                    failure: (void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) getDriverLocation: (NSNumber *) driverId
                    success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                    failure: (void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

@end
