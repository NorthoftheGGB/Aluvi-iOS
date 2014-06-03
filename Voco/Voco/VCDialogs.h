//
//  VCDialogs.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Offer.h"

@interface VCDialogs : NSObject

+ (void) offerNextRideToDriver;
+ (void) offerRideToDriver: (Offer *) rideOffer;

@end
