//
//  VCRiderApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>
#import "Ride.h"
#import "VCRideRequestCreated.h"

@interface VCRiderApi : NSObject

+ (void) setup: (RKObjectManager *) objectManager;

+ (void) requestRide:(Ride *) ride
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , VCRideRequestCreated * response ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) cancelRide:(Ride *) ride
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) refreshScheduledRidesWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) payments:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
          failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;


@end
