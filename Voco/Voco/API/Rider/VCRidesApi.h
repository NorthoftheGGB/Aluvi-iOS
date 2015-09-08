//
//  VCRiderApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Ticket.h"
#import "VCCommuterRideRequestCreated.h"
#import "VCCommuterRideRequest.h"

@interface VCRidesApi : NSObject

+ (void) setup: (RKObjectManager *) objectManager;

+ (void) requestRide:(VCCommuterRideRequest *) request
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , VCCommuterRideRequestCreated * response ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) cancelRide:(Ticket *) ride
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) refreshScheduledRidesWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) payments:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
          failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) cancelTrip:(NSNumber *) tripId
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure ;

+ (void) getPickupPointsWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure ;

+ (void) refreshReceiptsWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

@end
