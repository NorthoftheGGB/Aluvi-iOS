//
//  VCRideRequestCreated.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
@interface VCRideRequestCreated : NSObject

@property (nonatomic, strong) NSNumber * rideId;
@property (nonatomic, strong) NSNumber * tripId;

+ (RKObjectMapping *) getMapping;

@end
