//
//  Transport.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Fare.h"
#import "Offer.h"
#import "VCApi.h"

@interface Fare ()

@end

@implementation Fare

@dynamic car_id;
@dynamic offer;

- (id) init{
    self = [super init];
    if(self != nil){
        
    }
    return self;
}


+ (void)createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Fare"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"fare_id",
                                                        @"state" : @"savedState",
                                                        @"meeting_point_place_name" : @"meetingPointPlaceName",
                                                        @"meeting_point_latitude" : @"meetingPointLatitude",
                                                        @"meeting_point_longitude" : @"meetingPointLongitude",
                                                        @"drop_off_point_place_name" : @"dropOffPointPlaceName",
                                                        @"drop_off_point_latitude" : @"dropOffPointLatitude",
                                                        @"drop_off_point_longitude" : @"dropOffPointLongitude",
                                                        @"pickup_time" : @"pickupTime"
                                                        }];
    
    
    entityMapping.identificationAttributes = @[ @"fare_id" ];
    
    /*
     [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
     RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:API_GET_SCHEDULED_RIDES];
     
     NSString * relativePath = [URL relativePath];
     NSDictionary *argsDict = nil;
     BOOL match = [pathMatcher matchesPath:relativePath tokenizeQueryStrings:NO parsedArguments:&argsDict];
     if (match) {
     NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Fare"];
     return fetchRequest;
     }
     
     return nil;
     }];
     */
    
    {
        RKResponseDescriptor * responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                     method:RKRequestMethodGET
                                                pathPattern:API_GET_DRIVER_RIDE_PATH_PATTERN
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKResponseDescriptor * responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                     method:RKRequestMethodGET
                                                pathPattern:API_GET_ACTIVE_FARES
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    
    
    
    
}

- (void) markOfferAsAccepted {
    
    Offer * rideOffer = [self getOffer];
    if(rideOffer != nil) {
        [rideOffer markAsAccepted];
    }
    
}

- (void) markOfferAsDeclined {
    Offer *  rideOffer = [self getOffer];
    if(rideOffer != nil) {
        [rideOffer markAsDeclined];
    }
}

- (void) markOfferAsClosed {
    Offer *  rideOffer = [self getOffer];
    if(rideOffer != nil) {
        [rideOffer markAsClosed];
    }
}

- (Offer *) getOffer {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Offer"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fare_id = %@", self.fare_id];
    [request setPredicate:predicate];
    NSError * error;
    NSArray * results = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
    if(results == nil){
        [WRUtilities criticalError:error];
        return nil;
    }
    return results.firstObject;
    
}

#pragma mark state machine methods
- (void) assignStatesAndEvents:(TKStateMachine *) stateMachine{
    // Nothing for now
}

- (NSString *) getInitialState {
    return @"exists"; // Placeholder
}

- (NSString *) routeDescription {
    return [NSString stringWithFormat:@"%@ to %@", self.meetingPointPlaceName, self.dropOffPointPlaceName];
}
@end
