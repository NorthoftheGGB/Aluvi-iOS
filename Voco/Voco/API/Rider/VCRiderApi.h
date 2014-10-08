//
//  VCRiderApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>
#import "Ticket.h"
#import "VCRideRequestCreated.h"

@interface VCRiderApi : NSObject

+ (void) setup: (RKObjectManager *) objectManager;

+ (void) requestRide:(Ticket *) ride
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , VCRideRequestCreated * response ))success
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

@end
