//
//  VCRiderApi.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRidesApi.h"
#import "VCApi.h"
#import "VCDevice.h"
#import "Ticket.h"
#import "VCRideIdentity.h"
#import "VCUserStateManager.h"
#import "VCRequestUpdate.h"
#import "Payment.h"
#import "VCPickupPoint.h"
#import "Receipt.h"


@implementation VCRidesApi

+ (void) setup: (RKObjectManager *) objectManager {
    
    RKEntityMapping * ticketMapping = [Ticket createMappings:objectManager];
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_GET_ACTIVE_TICKETS];
        
        NSString * relativePath = [URL relativePath];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:relativePath tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            // needs to return what needs to be delete
            // i.e. tickets that are not in the new batch
            // or just delete tickets that are no longer relevant???
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
            return fetchRequest;
        }
        return nil;
    }];
    
    
    {
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:ticketMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_ACTIVE_TICKETS
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:ticketMapping
                                                                                                 method:RKRequestMethodPOST
                                                                                            pathPattern:API_POST_RIDE_CANCELLED
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];

    }
    {
        
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:ticketMapping
                                                                                                 method:RKRequestMethodFromString(@"DELETE")
                                                                                            pathPattern:API_DELETE_TRIP
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    

    
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
        
        
        
          }
    {
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:ticketMapping
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
    
    {
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[Receipt createMappings:objectManager]
                                                                                                 method:RKRequestMethodGET
                                                                                            pathPattern:API_GET_RECEIPTS
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
        
        [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
            RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_GET_RECEIPTS];
            
            NSString * relativePath = [URL relativePath];
            NSDictionary *argsDict = nil;
            BOOL match = [pathMatcher matchesPath:relativePath tokenizeQueryStrings:NO parsedArguments:&argsDict];
            if (match) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Receipt"];
                return fetchRequest;
            }
            return nil;
        }];
        
    }

}

+ (void) requestRide:(VCCommuterRideRequest *) request
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult * mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [[VCDebug sharedInstance] apiLog:@"API: request ride"];
    
    [[RKObjectManager sharedManager] postObject:request
                                           path: API_POST_RIDE_REQUEST
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [[VCDebug sharedInstance] apiLog:@"API: request ride success"];
                                            
                                            NSLog(@"Ride request accepted by server!");
                                            
                                            success(operation, mappingResult);
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


+ (void) refreshReceiptsWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_RECEIPTS parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  success(operation, mappingResult);
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  failure(operation, error);
                                              }];
}



@end
