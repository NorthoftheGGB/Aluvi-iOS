//
//  VCRiderApi.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderApi.h"
#import "VCApi.h"
#import "VCCommuterRideRequestCreated.h"
#import "VCDevice.h"
#import "Ticket.h"
#import "VCRideIdentity.h"
#import "VCUserStateManager.h"
#import "VCRequestUpdate.h"
#import "Payment.h"
#import "VCPickupPoint.h"


@implementation VCRiderApi

+ (void) setup: (RKObjectManager *) objectManager {
    
    [Ticket createMappings:objectManager];
    [Payment createMappings:objectManager];
    
    {
        RKObjectMapping * objectMapping = [VCCommuterRideRequest getMapping];
        RKObjectMapping * postRideRequestMapping = [objectMapping inverseMapping];
        RKRequestDescriptor *requestDescriptorPostData = [RKRequestDescriptor requestDescriptorWithMapping:postRideRequestMapping objectClass:[VCCommuterRideRequest class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptorPostData];
    }
    
    {
        RKObjectMapping * objectMapping = [VCRideIdentity getMapping];
        RKObjectMapping * requestMapping = [objectMapping inverseMapping];
        
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCRideIdentity class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptor];
        
        
        
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                                 method:RKRequestMethodPOST
                                                                                            pathPattern:API_POST_RIDE_CANCELLED
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKObjectMapping * mapping = [VCCommuterRideRequestCreated getMapping];
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
        RKObjectMapping * mapping = [VCPickupPoint getMapping];
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                 method:RKRequestMethodGET
                                                                                            pathPattern:API_GET_PICKUP_POINTS keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
        
    }

}

+ (void) requestRide:(VCCommuterRideRequest *) request
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , VCCommuterRideRequestCreated * response ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [[VCDebug sharedInstance] apiLog:@"API: request ride"];
    
    [[RKObjectManager sharedManager] postObject:request
                                           path: API_POST_RIDE_REQUEST
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [[VCDebug sharedInstance] apiLog:@"API: request ride success"];
                                            
                                            NSLog(@"Ride request accepted by server!");
                                            
                                            
                                            VCCommuterRideRequestCreated * response  = mappingResult.firstObject;
                                            
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
    
    
    [[VCDebug sharedInstance] apiLog:@"API: cancel ride"];
    
    // Alread have a ride id, so this is a ride cancellation
    [[RKObjectManager sharedManager] postObject:nil path:API_POST_RIDE_CANCELLED parameters:@{@"ride_id" : ride.ride_id}
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            
                                            [[VCDebug sharedInstance] apiLog:@"API: Rider cancel ride success"];
                                            
                                            NSError * error = nil;
                                            ride.state = kRiderCancelledState;
                                            
                                            // Get ride of the tickets and trip if they aren't relevant now
                                            NSArray * tickets = [Ticket ticketsForTrip:ride.trip_id];
                                            BOOL stillActive = NO;
                                            for(Ticket* ticket in tickets){
                                                if([@[kScheduledState, kInProgressState, kCompleteState] containsObject:ticket.state]){
                                                    stillActive = YES;
                                                }
                                            }
                                            if( !stillActive ){
                                                for(Ticket* ticket in tickets){
                                                    [[VCCoreData managedObjectContext] deleteObject:ticket];
                                                }
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
        
                                              
        NSArray * tickets = [Ticket ticketsForTrip:tripId];
        for(Ticket* ticket in tickets){
            [[VCCoreData managedObjectContext] deleteObject:ticket];
        }
        
        NSError * error;
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


+ (void) getPickupPointsWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                 failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
  
    [[RKObjectManager sharedManager]  getObjectsAtPath:API_GET_PICKUP_POINTS
                                            parameters:nil
                                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                   success(operation, mappingResult);
                                               }
                                               failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                   failure(operation, error);
                                               }];

}




@end
