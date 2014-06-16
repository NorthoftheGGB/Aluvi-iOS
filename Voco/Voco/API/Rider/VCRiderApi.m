//
//  VCRiderApi.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderApi.h"
#import "VCApi.h"
#import "VCRideRequest.h"
#import "VCRideRequestCreated.h"
#import "VCDevice.h"
#import "Ride.h"

@implementation VCRiderApi

+ (void) setup: (RKObjectManager *) objectManager {
    //RKObjectManager * objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
    
    // RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];

    [VCRideRequest createMappings:objectManager];
    [VCRideRequestCreated createMappings:objectManager];
    [VCDevice createMappings:objectManager];
    [Ride createMappings:objectManager];
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);

    
}

+ (void) requestRide:(Ride *) ride
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [[RKObjectManager sharedManager] postObject:[VCRideRequest requestForRide:ride]
                                           path: API_POST_RIDE_REQUEST
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NSLog(@"Ride request accepted by server!");
                                            
                                            VCRideRequestCreated * response = mappingResult.firstObject;
                                            ride.request_id = response.rideRequestId;
                                            
                                            NSError *error;
                                            [[VCCoreData managedObjectContext] save:&error];
                                            if(error != nil){
                                                [WRUtilities criticalError:error];
                                            }
                                            success(operation, mappingResult);
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            
                                            NSLog(@"Failed send request %@", error);
                                            [WRUtilities criticalError:error];
                                            failure(operation, error);
                                        }];
}

@end
