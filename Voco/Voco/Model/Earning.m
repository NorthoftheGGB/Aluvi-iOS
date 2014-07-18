//
//  Earning.m
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Earning.h"
#import "Fare.h"
#import <RKPathMatcher.h>
#import "VCApi.h"


@implementation Earning

@dynamic amountCents;
@dynamic capturedAt;
@dynamic driver_id;
@dynamic fare_id;
@dynamic id;
@dynamic ride_id;
@dynamic stripeChargeStatus;
@dynamic fare;
@dynamic createdAt;
@dynamic motive;

+ (void)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Earning"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"id",
                                                        @"fare_id" : @"fare_id",
                                                        @"ride_id" : @"ride_id",
                                                        @"driver_id" : @"driver_id",
                                                        @"captured_at" : @"capturedAt",
                                                        @"amount_cents" : @"amountCents",
                                                        @"stripe_charge_status" : @"stripeChargeStatus",
                                                        @"created_at" : @"createdAt",
                                                        @"initiation" : @"motive"
                                                        }];
    
    entityMapping.identificationAttributes = @[ @"id" ];
    
    /*
     This caused receipts not to be found after logout/login
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_GET_EARNINGS];
        
        NSString * relativePath = [URL relativePath];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:relativePath tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Earning"];
            return fetchRequest;
        }
        
        return nil;
    }];
     */
    
    [entityMapping addConnectionForRelationship:@"fare" connectedBy:@{@"fare_id" : @"ride_id"}];
   
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_EARNINGS
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
}

@end
