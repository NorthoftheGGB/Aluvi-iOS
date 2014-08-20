//
//  VCDialogs.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIAlertView+Blocks.h>
#import "Offer.h"
#import "Ticket.h"

#define VC_INTERFACE_STATE_IDLE @"VC_INTERFACE_STATE_IDLE"
#define VC_INTERFACE_STATE_OFFER_DIALOG @"VC_INTERFACE_STATE_OFFER_DIALOG"

@interface VCDialogs : NSObject

@property(nonatomic, strong) NSString * interfaceState;

+ (VCDialogs *) instance;

- (void) offerNextFareToDriver;
- (void) offerFareToDriver: (Offer *) offer;
- (void) retractOfferDialog: (Offer *) offer;
- (void) rideFound: (NSNumber *) requestId;
- (void) rideCancelledByRider;
- (void) rideCancelledByDriver;
- (void) showRideReceipt: (NSNumber *) rideId amount: (NSNumber *) amount;
- (void) commuterRideFound: (Ticket *) request;
- (void) rideAssigned: (Fare *) ride;
- (void) commuterRideAlarm: (NSNumber *) requestId;
- (void) showRidePaymentProblem: (NSNumber *) rideId;
- (void) commuteFulfilled;
- (void) commuteUnfulfilled;
@end
