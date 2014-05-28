//
//  VCRideRequest.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <RestKit.h>

#define RIDE_REQUEST_TYPE_ON_DEMAND @"on_demand"
#define RIDE_REQUEST_TYPE_COMMUTER @"commuter"

@interface VCRideRequest : NSObject

@property (nonatomic) NSInteger customerId;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSNumber * departureLatitude;
@property (nonatomic, strong) NSNumber * departureLongitude;
@property (nonatomic, strong) NSNumber * destinationLatitude;
@property (nonatomic, strong) NSNumber * destinationLongitude;

+ (void) createMappings: (RKObjectManager *) objectManager;

@end
