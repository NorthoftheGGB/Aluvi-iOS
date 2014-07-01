//
//  Transport.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Drive.h"
#import "VCApi.h"

@interface Drive ()

@end

@implementation Drive

@dynamic car_id;


- (id) init{
    self = [super init];
    if(self != nil){
        
    }
    return self;
}


+ (void)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Drive"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
#warning using savedState instead of forcedState to work around KVO compliancy error
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"ride_id",
                                                        @"state" : @"savedState",
                                                        @"meeting_point_place_name" : @"meetingPointPlaceName",
                                                        @"meeting_point_latitude" : @"meetingPointLatitude",
                                                        @"meeting_point_longitude" : @"meetingPointLongitude",
                                                        @"destination_place_name" : @"destinationPlaceName",
                                                        @"destination_latitude" : @"destinationLatitude",
                                                        @"destination_longitude" : @"destinationLongitude",
                                                        }];
    
    
    entityMapping.identificationAttributes = @[ @"ride_id" ];
    
    
    
    /*
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_GET_SCHEDULED_RIDES];
        
        NSString * relativePath = [URL relativePath];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:relativePath tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ride"];
            return fetchRequest;
        }
        
        return nil;
    }];
     */

    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:API_GET_DRIVER_RIDE_PATH_PATTERN
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    
       
    
}


@end
