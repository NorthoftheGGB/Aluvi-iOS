//
//  Transport.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Trip.h"

@class Offer;

@interface Ride : Trip

@property (nonatomic, retain) NSNumber * car_id;
@property (nonatomic, retain) Offer *offer; //TODO: Not used at the moment because of no good place to assign to graph


+ (void)createMappings:(RKObjectManager *)objectManager;

- (void) markOfferAsAccepted;
- (void) markOfferAsDeclined;
- (void) markOfferAsClosed;

@end
