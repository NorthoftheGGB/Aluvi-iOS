//
//  Earning.m
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Earning.h"
#import <RKPathMatcher.h>
#import "Rider.h"
#import "Ticket.h"
#import "VCApi.h"

@implementation Earning

@dynamic amountCents;

@dynamic ticket_id;
@dynamic timestamp;
@dynamic motive;

+ (void)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Earning"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"ticket_id" : @"ticket_id",
                                                        @"amount_cents" : @"amountCents",
                                                        @"timestamp" : @"timestamp",
                                                        @"motive" : @"motive"
                                                        }];
    
    entityMapping.identificationAttributes = @[ @"ticket_id" ];
   
    
    [entityMapping addConnectionForRelationship:@"ticket" connectedBy:@{@"ticket_id" : @"ride_id"}];

    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_EARNINGS
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
}

@end
