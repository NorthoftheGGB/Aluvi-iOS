//
//  Earning.m
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Earning.h"
#import "Fare.h"
#import "Rider.h"
#import <RKPathMatcher.h>
#import "VCApi.h"


@implementation Earning

@dynamic amountCents;

@dynamic fare_id;
@dynamic timestamp;
@dynamic motive;
@dynamic fare;

+ (void)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Earning"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"fare_id" : @"fare_id",
                                                        @"amount_cents" : @"amountCents",
                                                        @"timestamp" : @"timestamp",
                                                        @"motive" : @"motive"
                                                        }];
    
    entityMapping.identificationAttributes = @[ @"fare_id" ];
    
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
    
    //[entityMapping addConnectionForRelationship:@"fare" connectedBy:@{@"fare_id" : @"fare_id"}];
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"fare" mapping:[Fare createMappings:objectManager]];

    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_EARNINGS
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
}

@end
