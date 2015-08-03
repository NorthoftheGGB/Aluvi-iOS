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
#import "Ticket.h"
#import "VCRideIdentity.h"
#import "VCUserStateManager.h"
#import "VCRequestUpdate.h"
#import "Payment.h"


@implementation VCRiderApi

+ (void) setup: (RKObjectManager *) objectManager {
    
    [Ticket createMappings:objectManager];
    [Payment createMappings:objectManager];
    
    {
        RKObjectMapping * objectMapping = [VCRideRequest getMapping];
        RKObjectMapping * postRideRequestMapping = [objectMapping inverseMapping];
        RKRequestDescriptor *requestDescriptorPostData = [RKRequestDescriptor requestDescriptorWithMapping:postRideRequestMapping objectClass:[VCRideRequest class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptorPostData];
    }
    
    {
        RKObjectMapping * objectMapping = [VCRideIdentity getMapping];
        RKObjectMapping * requestMapping = [objectMapping inverseMapping];
        
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCRideIdentity class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptor];
        
        
        
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                                 method:RKRequestMethodPOST
                                                                                            pathPattern:API_POST_RIDER_CANCELLED
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKObjectMapping * mapping = [VCRideRequestCreated getMapping];
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                 method:RKRequestMethodPOST
                                                                                            pathPattern:API_POST_RIDE_REQUEST keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
        
    }
    {
        RKObjectMapping * mapping = [VCRequestUpdate getMapping];
        RKObjectMapping * requestMapping = [mapping inverseMapping];
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCRequestUpdate class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptor];
    }
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

+ (void) requestRide:(Ticket *) ride
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , VCRideRequestCreated * response ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [[VCDebug sharedInstance] apiLog:@"API: request ride"];
    
    [[RKObjectManager sharedManager] postObject:[VCRideRequest requestForRide:ride]
                                           path: API_POST_RIDE_REQUEST
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [[VCDebug sharedInstance] apiLog:@"API: request ride success"];
                                            
                                            NSLog(@"Ride request accepted by server!");
                                            
                                            VCRideRequestCreated * response = mappingResult.firstObject;
                                            ride.ride_id = response.rideId;
                                            ride.trip_id = response.tripId;
                                            
                                            NSError * error;
                                            [[VCCoreData managedObjectContext] save:&error];
                                            if(error != nil){
                                                [WRUtilities criticalError:error];
                                            }
                                            //[VCUserState instance].riderState = kUser;
                                            
                                            success(operation, response);
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [[VCDebug sharedInstance] apiLog:@"API: request ride failure"];
                                            
                                            NSLog(@"Failed send request %@", error);
                                            failure(operation, error);
                                        }];
}


+ (void) cancelRide:(Ticket *) ride
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    
    if(ride.fare_id != nil){
        [[VCDebug sharedInstance] apiLog:@"API: Rider cancel ride"];
        
        // Alread have a ride id, so this is a ride cancellation
        [[RKObjectManager sharedManager] postObject:nil path:API_POST_RIDER_CANCELLED parameters:@{@"fare_id" : ride.fare_id}
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                
                                                [[VCDebug sharedInstance] apiLog:@"API: Rider cancel ride success"];
                                                
                                                NSError * error = nil;
                                                [[VCCoreData managedObjectContext] deleteObject:ride];
                                                [[VCCoreData managedObjectContext] save:&error];
                                                if(error != nil){
                                                    [WRUtilities criticalError:error];
                                                }
                                                
                                                success(operation, mappingResult);
                                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                [[VCDebug sharedInstance] apiLog:@"API: Rider cancel ride failure"];
                                                
                                                NSLog(@"Failed cancel ride %@", error);
                                                failure(operation, error);
                                            }];
    } else {
        
        /*  I do not believe this is used any more
            need to refactor cancellation
         
         */
        
        [[VCDebug sharedInstance] apiLog:@"API: Rider cancel request"];
        
        // No ride id yet, so this could be a request cancellation
        // OR a ride cancellation if the ride found message has not arrived
        // This control fork gets handled on the server side
        VCRequestUpdate * requestIdentity = [[VCRequestUpdate alloc] init];
        requestIdentity.rideId = ride.ride_id;
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

+ (void) cancelTrip:(NSNumber *) tripId
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    // TODO: Refactor to properly use deleteObject when Trip becomes a core data object
    [[RKObjectManager sharedManager] deleteObject:nil
                                             path: [API_DELETE_TRIP stringByReplacingOccurrencesOfString:@":trip_id"
                                                                                              withString:[tripId stringValue]]
                                       parameters:nil
                                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[VCDebug sharedInstance] apiLog:@"API: Rider cancel ride success"];
        
        NSError * error = nil;
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"trip_id = %@", tripId];
        [request setPredicate:predicate];
        NSArray * tickets = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
        if(tickets == nil){
            [WRUtilities criticalError:error];
        }
        for(Ticket* ticket in tickets){
            [[VCCoreData managedObjectContext] deleteObject:ticket];
        }
        
        [[VCCoreData managedObjectContext] save:&error];
        if(error != nil){
            [WRUtilities criticalError:error];
        }
        
        success(operation, mappingResult);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [[VCDebug sharedInstance] apiLog:@"API: Rider cancel ride failure"];
        
        NSLog(@"Failed cancel ride %@", error);
        failure(operation, error);
    }];
}



+ (void) refreshScheduledRidesWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    // Update all rides for this user using RestKit entity
    [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_ACTIVE_TICKETS parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_ACTIVE_FARES
                                                                                         parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                             success(operation, mappingResult);
                                                                                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                             failure(operation, error);
                                                                                         }];
                                                  
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
