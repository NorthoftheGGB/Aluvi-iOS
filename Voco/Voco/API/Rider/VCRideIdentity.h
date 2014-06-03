//
//  VCRideIdentity.h
//  Voco
//
//  Created by Matthew Shultz on 6/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRestKitMappableObject.h"

@interface VCRideIdentity : NSObject <VCRestKitMappableObject>

@property(nonatomic, strong) NSNumber * rideId;
@property(nonatomic, strong) NSNumber * riderId;

@end
