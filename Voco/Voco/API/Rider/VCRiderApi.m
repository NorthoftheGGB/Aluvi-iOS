//
//  VCRiderApi.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderApi.h"
#import <RestKit.h>
#import "VCApi.h"
#import "VCRideRequest.h"
#import "VCRideRequestCreated.h"

@implementation VCRiderApi

+ (void) setup {
    RKObjectManager * objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
    
    // RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];

    [VCRideRequest createMappings:objectManager];
    [VCRideRequestCreated createMappings:objectManager];
    
     RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);

    
}

@end
