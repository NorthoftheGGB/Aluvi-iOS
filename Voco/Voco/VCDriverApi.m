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
#import "VCRideIdentity.h"
#import "Offer.h"
#import "VCLocation.h"

@implementation VCDriverApi

+ (void) setup: (RKObjectManager *) objectManager {
    [VCRideDriverAssignment createMappings:objectManager];
    [VCRideIdentity createMappings:objectManager];
    [Offer createMappings:objectManager];
    [VCLocation createMappings:objectManager];
    
}
@end
