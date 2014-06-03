//
//  Offer.m
//  Voco
//
//  Created by Matthew Shultz on 6/2/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Offer.h"
#import <RestKit/RestKit.h>
#import <RestKit/Network/RKPathMatcher.h>

@implementation Offer

@dynamic ride_id;
@dynamic id;
@dynamic state;
@dynamic updatedAt;
@dynamic createdAt;
@dynamic decided;
@dynamic meetingPointPlaceName;
@dynamic destinationPlaceName;

+ (void)createMappings:(RKObjectManager *)objectManager {
    
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Offer"
                                                        inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{@"id": @"id",
                                                        @"ride_id" : @"ride_id",
                                                        @"state" : @"state",
                                                        @"created_at" : @"createdAt",
                                                        @"updated_at" : @"updatedAt",
                                                      //  @"meeting_point_place_name" : @"meetingPointPlaceName",
                                                        @"destination_place_name" : @"destinationPlaceName"}];
    entityMapping.identificationAttributes = @[ @"id" ];

    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher * pathMatcher;
        pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_GET_RIDE_OFFERS_PATH_PATTERN];
        
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Offer"];
            //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"decided = %@", [NSNumber numberWithBool:NO]];
            //[fetchRequest setPredicate:predicate];
            return fetchRequest;
        }
        
        return nil;
    }];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_RIDE_OFFERS_PATH_PATTERN
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

}

@end
