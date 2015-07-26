//
//  VCGeoApi.m
//  Voco
//
//  Created by Matthew Shultz on 7/4/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCGeoApi.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>#import "VCApi.h"

@implementation VCGeoApi

+ (void) setup: (RKObjectManager *) objectManager {
    {
    RKObjectMapping * mapping = [VCGeoObject getMapping];
    
    RKObjectMapping * requestMapping = [mapping inverseMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCGeoObject class] rootKeyPath:nil method:RKRequestMethodPUT];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[VCGeoObject class] pathPattern:API_GEO_DRIVER_PATH method:RKRequestMethodPUT]];
    [objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[VCGeoObject class] pathPattern:API_GEO_DRIVER_PATH method:RKRequestMethodGET]];
    
    
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                                 method:RKRequestMethodPUT
                                                                                            pathPattern:API_GEO_DRIVER_PATH
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    
    
    }
    {
        RKObjectMapping * mapping = [VCDriverGeoObject getMapping];
        RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:API_GEO_DRIVER_PATH
                                                                                                 keyPath:nil
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor2];
        
    }

}

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
