//
//  VCDriverApi.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverApi.h"
#import "VCApi.h"
#import "VCRideOffer.h"
#import "VCRideDriverAssignment.h"
#import "Offer.h"

@implementation VCDriverApi

+ (void) setup: (RKObjectManager *) objectManager {
    // RKObjectManager * objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
    // RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    [VCRideDriverAssignment createMappings:objectManager];
    [Offer createMappings:objectManager];
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    
}
@end
