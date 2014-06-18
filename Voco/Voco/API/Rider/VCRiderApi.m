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
#import "VCRideIdentity.h"
#import "VCUserState.h"
#import "VCRequestUpdate.h"

@implementation VCRiderApi

+ (void) setup: (RKObjectManager *) objectManager {
    [VCRideRequest createMappings:objectManager];
    [VCRideRequestCreated createMappings:objectManager];
    [VCDevice createMappings:objectManager];
    [Ride createMappings:objectManager];
    [VCRequestUpdate createMappings:objectManager];
    
    // Responses (All responses should be moved here)
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
                                            //[VCUserState instance].riderState = kUser;

                                            success(operation, mappingResult);
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            
                                            NSLog(@"Failed send request %@", error);
                                            failure(operation, error);
                                        }];
}


+ (void) cancelRide:(Ride *) ride
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
 
    if(ride.ride_id != nil){
        VCRideIdentity * rideIdentity = [[VCRideIdentity alloc] init];
        rideIdentity.rideId = ride.ride_id;
        [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDER_CANCELLED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [VCUserState instance].riderState = kUserStateIdle;
                                            success(operation, mappingResult);
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            NSLog(@"Failed cancel ride %@", error);
                                            failure(operation, error);
                                        }];
    } else {
        VCRequestUpdate * requestIdentity = [[VCRequestUpdate alloc] init];
        requestIdentity.requestId = ride.request_id;
        [[RKObjectManager sharedManager] postObject:requestIdentity path:API_POST_REQUEST_CANCELLED parameters:nil
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                
                                                [VCUserState instance].riderState = kUserStateIdle;
                                                
                                                [[VCCoreData managedObjectContext] deleteObject:ride];
                                                NSError *error;
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


@end
