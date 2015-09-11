//
//  VCDriverApi.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverApi.h"
#import "VCApi.h"
#import "VCRideIdentity.h"
#import "VCTicketPayload.h"
#import "VCGeoObject.h"
#import "VCDriverGeoObject.h"
#import "Earning.h"
#import "VCApiError.h"
#import "Ticket.h"

@implementation VCDriverApi

+ (void) setup: (RKObjectManager *) objectManager {
    
    {
        RKObjectMapping * mapping = [VCTicketPayload getMapping];
        RKObjectMapping * requestMapping = [mapping inverseMapping];
        RKRequestDescriptor *requestDescriptorPostData = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCTicketPayload class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptorPostData];
    }
    {
        RKObjectMapping * mapping = [Car createMappings:objectManager];
        RKObjectMapping * requestMapping = [mapping inverseMapping];
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Car class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptor];
    }
    
    RKEntityMapping * ticketMapping = [Ticket createMappings:objectManager];

    {
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:ticketMapping
                                                                                                     method:RKRequestMethodPOST
                                                                                                pathPattern:API_POST_RIDE_COMPLETED
                                                                                                    keyPath:nil
                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
        
        
        [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
            RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_POST_RIDE_COMPLETED];
            
            NSString * relativePath = [URL relativePath];
            NSDictionary *argsDict = nil;
            BOOL match = [pathMatcher matchesPath:relativePath tokenizeQueryStrings:NO parsedArguments:&argsDict];
            if (match) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
                return fetchRequest;
            }
            return nil;
        }];

    }
    
    
    
    {
        
        RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:ticketMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:API_POST_RIDE_PICKUP
                                                                                                 keyPath:nil
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor2];
        
        
        // We could also just return the single ticket
        // however syncing all tickets has this appeal
        [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
            RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_POST_RIDE_COMPLETED];
            
            NSString * relativePath = [URL relativePath];
            NSDictionary *argsDict = nil;
            BOOL match = [pathMatcher matchesPath:relativePath tokenizeQueryStrings:NO parsedArguments:&argsDict];
            if (match) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
                return fetchRequest;
            }
            return nil;
        }];

    }
    
}




+ (void) ridersPickedUp: (NSNumber *) ticketId
                success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure

{
    VCTicketPayload * ticketPayload = [[VCTicketPayload alloc] init];
    ticketPayload.ticketId = ticketId;
      [[RKObjectManager sharedManager] postObject:ticketPayload path:API_POST_RIDE_PICKUP parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
          success(operation, mappingResult);
      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
          failure(operation, error);
      }];
}

+ (void) ticketCompleted: (NSNumber *) ticketId
                       success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCTicketPayload * ticketPayload = [[VCTicketPayload alloc] init];
    ticketPayload.ticketId = ticketId;
    
    [[RKObjectManager sharedManager] postObject:ticketPayload path:API_POST_RIDE_COMPLETED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
    
}




@end
