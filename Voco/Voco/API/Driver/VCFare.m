//
//  VCFare.m
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCFare.h"
#import "VCApi.h"

@implementation VCFare

+ (void)createMappings:(RKObjectManager *)objectManager {
    
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id" : @"id",
                                                  @"amount" : @"amount",
                                                  @"driver_earnings" : @"driverEarnings"
                                                  }];

     {
         RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                   method:RKRequestMethodPOST
                                                                                              pathPattern:API_POST_RIDE_ARRIVED
                                                                                                  keyPath:nil
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
         [objectManager addResponseDescriptor:responseDescriptor];
     }
}
@end
