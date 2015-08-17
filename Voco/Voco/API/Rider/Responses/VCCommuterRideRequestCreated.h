//
//  VCRideRequestCreated.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
@interface VCCommuterRideRequestCreated : NSObject

@property (nonatomic, strong) NSNumber * outgoingRideId;
@property (nonatomic, strong) NSNumber * returnRideId;
@property (nonatomic, strong) NSNumber * tripId;

+ (RKObjectMapping *) getMapping;

@end
