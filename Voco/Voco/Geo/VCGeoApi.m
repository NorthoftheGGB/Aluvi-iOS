//
//  VCGeoApi.m
//  Voco
//
//  Created by Matthew Shultz on 7/4/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCGeoApi.h"
#import <RestKit.h>
#import "VCApi.h"
#import "VCGeoObject.h"

@implementation VCGeoApi

+ (void) sendDriverLocation: (CLLocation *) location
                    success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                    failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure
{
    VCGeoObject * objectLocation = [[VCGeoObject alloc] init];
    objectLocation.objectId = [NSNumber numberWithInt:0];
    objectLocation.latitude = [NSNumber numberWithDouble: location.coordinate.latitude];
    objectLocation.longitude = [NSNumber numberWithDouble: location.coordinate.longitude];
    [[RKObjectManager sharedManager] putObject:objectLocation
                                          path:nil
                                    parameters:nil
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           success(operation, mappingResult);
                                       }
                                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                           failure(operation, error);
                                       }];
    
}


+ (void) getDriverLocation: (NSNumber *) driverId
                   success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                   failure: (void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    VCGeoObject * geoObject = [[VCGeoObject alloc] init];
    geoObject.objectId = driverId;
    
    [[RKObjectManager sharedManager] getObject:geoObject
                                          path:nil
                                    parameters:nil
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                              success(operation, mappingResult);
                                          }
                                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                              failure(operation, error);
                                          }];
    
}

@end
