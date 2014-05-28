//
//  VCRideRequestCreated.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>

@interface VCRideRequestCreated : NSObject

@property (nonatomic, strong) NSNumber * rideRequestId;

+ (void) createMappings: (RKObjectManager *) objectManager;

@end
