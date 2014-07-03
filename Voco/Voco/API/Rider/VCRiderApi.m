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
#import "Request.h"
#import "VCRideIdentity.h"
#import "VCUserState.h"
#import "VCRequestUpdate.h"

@implementation VCRiderApi

+ (void) setup: (RKObjectManager *) objectManager {
    [VCRideRequest createMappings:objectManager];
    [VCRideRequestCreated createMappings:objectManager];
    [VCDevice createMappings:objectManager];
    [Request createMappings:objectManager];
    [VCRequestUpdate createMappings:objectManager];
    
    // Responses (some have not been moved here yet)
    {
        RKResponseDescriptor * responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                     method:RKRequestMethodPOST
                                                pathPattern:API_POST_REQUEST_CANCELLED
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
  }

+ (void) requestRide:(Request *) ride
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [[RKObjectManager sharedManager] postObject:[VCRideRequest requestForRide:ride]
                                           path: API_POST_RIDE_REQUEST
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NSLog(@"Ride request accepted by server!");
                                            
                                            NSError * error = nil;
                                            [ride fireEvent:kEventRideRequested userInfo:@{} error:&error];
                                            if(error != nil){
                                                [WRUtilities criticalError:error];
                                            }
                                            
                                            VCRideRequestCreated * response = mappingResult.firstObject;
                                            ride.request_id = response.rideRequestId;
                                            
                                            [[VCCoreData managedObjectContext] save:&error];
                                            if(error != nil){
                                                [WRUtilities criticalError:error];
                                            }
                                            //[VCUserState instance].riderState = kUser;

                                            success(operation, mappingResult);
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            
                                            NSLog(@"Failed send request %@", error);
                                            failure(operation, error);
                                        }];
}


+ (void) cancelRide:(Request *) ride
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
        if(ride.ride_id != nil){
            // Alread have a ride id, so this is a ride cancellation
            VCRideIdentity * rideIdentity = [[VCRideIdentity alloc] init];
            rideIdentity.rideId = ride.ride_id;
            [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDER_CANCELLED parameters:nil
                                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                    NSError * error;
                                                    [ride fireEvent:kEventRideCancelledByRider userInfo:@{} error:&error];
                                                    if(error != nil){
                                                        [WRUtilities criticalError:error];
                                                    }
                                                    [[VCCoreData managedObjectContext] save:&error];

                                                    success(operation, mappingResult);
                                                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                    NSLog(@"Failed cancel ride %@", error);
                                                    failure(operation, error);
                                                }];
        } else {
            // No ride id yet, so this could be a request cancellation
            // OR a ride cancellation if the ride found message has not arrived
            // This control fork gets handled on the server side
            VCRequestUpdate * requestIdentity = [[VCRequestUpdate alloc] init];
            requestIdentity.requestId = ride.request_id;
            [[RKObjectManager sharedManager] postObject:requestIdentity path:API_POST_REQUEST_CANCELLED parameters:nil
                                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                    
                                                    NSError * error = nil;
                                                    [ride fireEvent:kEventRideCancelledByRider userInfo:@{} error:&error];
                                                    if(error != nil){
                                                        [WRUtilities criticalError:error];
                                                    }
                                                    
                                                    [[VCCoreData managedObjectContext] deleteObject:ride];
                                                    [[VCCoreData managedObjectContext] save:&error];
                                                    if(error != nil){
                                                        [WRUtilities criticalError:error];
                                                    }
                                                    
                                                    success(operation, mappingResult);
                                                    
                                                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                    NSLog(@"Failed cancel ride %@", error);
                                                    failure(operation, error);
                                                }];
        }

}

+ (void) refreshScheduledRidesWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    // Update all rides for this user using RestKit entity
    [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_SCHEDULED_RIDES parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  // It's completely possible that state is out of sync with the server
                                                  // May need to update state here
                                                  // How to detect state change on the server ?
                                                  
                                                  success(operation, mappingResult);
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  
                                                  failure(operation, error);
                                                  
                                              }];
}


@end
