//
//  VCPushApi.h
//  Voco
//
//  Created by Matthew Shultz on 6/2/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VC_PUSH_TYPE_KEY @"type"
#define VC_PUSH_OFFER_ID_KEY @"offer_id"
#define VC_PUSH_RIDE_ID_KEY @"ride_id"
#define VC_PUSH_FARE_ID_KEY @"fare_id"
#define VC_PUSH_AMOUNT_KEY @"amount"
#define VC_PUSH_FARE_ID_KEY @"fare_id"

#define kPushTypeRideFound @"fare_found"
#define kPushTypeFareAssigned @"fare_assigned"
#define kPushTypeFareCancelledByRider @"fare_cancelled_by_rider"
#define kPushTypeFareCancelledByDriver @"fare_cancelled_by_driver"
#define kPushTypeRideReceipt @"ride_receipt"
#define kPushTypeRidePaymentProblems @"ride_payment_problem"
#define kPushTypeNoDriversAvailable @"no_drivers_available"
#define kPushTypeUserStateChanged @"user_state_change"
#define kPushTypeRideOffer @"ride_offer"
#define kPushTypeRideOfferClosed @"ride_offer_closed"

// Internal Notifications
#define kNotificationTypeFareComplete @"fare_complete"

@interface VCPushApi : NSObject

@end
