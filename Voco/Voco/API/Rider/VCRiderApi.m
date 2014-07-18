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
#import "Payment.h"

@implementation VCRiderApi

+ (void) setup: (RKObjectManager *) objectManager {
    [VCRideRequest createMappings:objectManager];
    [VCRideRequestCreated createMappings:objectManager];
    [VCDevice createMappings:objectManager];
    [Ride createMappings:objectManager];
    [VCRequestUpdate createMappings:objectManager];
    [Payment createMappings:objectManager];
    
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

+ (void) requestRide:(Ride *) ride
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [[VCDebug sharedInstance] apiLog:@"API: request ride"];
    
    [[RKObjectManager sharedManager] postObject:[VCRideRequest requestForRide:ride]
                                           path: API_POST_RIDE_REQUEST
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [[VCDebug sharedInstance] apiLog:@"API: request ride success"];
                                            
                                            NSLog(@"Ride request accepted by server!");
                                            
                                            VCRideRequestCreated * response = mappingResult.firstObject;
                                            ride.request_id = response.rideRequestId;
                                            
                                            NSError * error;
                                            [[VCCoreData managedObjectContext] save:&error];
                                            if(error != nil){
                                                [WRUtilities criticalError:error];
                                            }
                                            //[VCUserState instance].riderState = kUser;
                                            
                                            success(operation, mappingResult);
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [[VCDebug sharedInstance] apiLog:@"API: request ride failure"];
                                            
                                            NSLog(@"Failed send request %@", error);
                                            failure(operation, error);
                                        }];
}


+ (void) cancelRide:(Ride *) ride
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    
    if(ride.ride_id != nil){
        [[VCDebug sharedInstance] apiLog:@"API: Rider cancel ride"];
        
        // Alread have a ride id, so this is a ride cancellation
        VCRideIdentity * rideIdentity = [[VCRideIdentity alloc] init];
        rideIdentity.rideId = ride.ride_id;
        [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDER_CANCELLED parameters:nil
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                
                                                [[VCDebug sharedInstance] apiLog:@"API: Rider cancel ride success"];
                                                
                                                NSError * error;
                                                [[VCCoreData managedObjectContext] save:&error];
                                                
                                                success(operation, mappingResult);
                                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                [[VCDebug sharedInstance] apiLog:@"API: Rider cancel ride failure"];
                                                
                                                NSLog(@"Failed cancel ride %@", error);
                                                failure(operation, error);
                                            }];
    } else {
        [[VCDebug sharedInstance] apiLog:@"API: Rider cancel request"];
        
        // No ride id yet, so this could be a request cancellation
        // OR a ride cancellation if the ride found message has not arrived
        // This control fork gets handled on the server side
        VCRequestUpdate * requestIdentity = [[VCRequestUpdate alloc] init];
        requestIdentity.requestId = ride.request_id;
        [[RKObjectManager sharedManager] postObject:requestIdentity path:API_POST_REQUEST_CANCELLED parameters:nil
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                [[VCDebug sharedInstance] apiLog:@"API: Rider cancel request success"];
                                                
                                                NSError * error = nil;
                                                
                                                [[VCCoreData managedObjectContext] deleteObject:ride];
                                                [[VCCoreData managedObjectContext] save:&error];
                                                if(error != nil){
                                                    [WRUtilities criticalError:error];
                                                }
                                                
                                                success(operation, mappingResult);
                                                
                                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                [[VCDebug sharedInstance] apiLog:@"API: Rider cancel request success"];
                                                
                                                NSLog(@"Failed cancel ride %@", error);
                                                failure(operation, error);
                                            }];
    }
    
}

+ (void) refreshScheduledRidesWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    // Update all rides for this user using RestKit entity
    [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_ACTIVE_REQUESTS parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  // It's completely possible that state is out of sync with the server
                                                  // May need to update state here
                                                  // How to detect state change on the server ?
                                                  
                                                  success(operation, mappingResult);
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  
                                                  failure(operation, error);
                                                  
                                              }];
}

+ (void) payments:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
          failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    [[RKObjectManager sharedManager]  getObjectsAtPath:API_GET_PAYMENTS
                                            parameters:nil
                                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                   success(operation, mappingResult);
                                               }
                                               failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                   failure(operation, error);
                                               }];
}



@end
