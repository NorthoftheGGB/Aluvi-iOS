//
//  VCDialogs.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDialogs.h"
#import <RestKit/RestKit.h>
#import "VCUserStateManager.h"
#import "NSDate+Pretty.h"
#import "VCUtilities.h"


static VCDialogs *sharedSingleton;

@interface VCDialogs ()

@property(nonatomic, strong) UIAlertView * currentAlertView;

@end

@implementation VCDialogs

+ (VCDialogs *) instance {
    if(sharedSingleton == nil){
        sharedSingleton = [[VCDialogs alloc] init];
        sharedSingleton.interfaceState = VC_INTERFACE_STATE_IDLE;
    }
    return sharedSingleton;
}

- (id) init {
    self = [super init];
    if(self != nil){
        _currentAlertView = nil;
    }
    return self;
}



- (void) rideFound: (NSNumber *) requestId {
    [UIAlertView showWithTitle:@"Ride Found!" message:@"Your ride has been scheduled" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    [VCUserStateManager instance].driveProcessState = kUserStateRideScheduled;
}

- (void) rideCancelledByRider {
    [UIAlertView showWithTitle:@"Ride Cancelled!" message:@"The rider cancelled the ride" cancelButtonTitle:@"OK" otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                      }];
    
}

- (void) rideCancelledByDriver {
    [UIAlertView showWithTitle:@"Ride Cancelled!" message:@"The driver cancelled the ride."
             cancelButtonTitle:@"OK" otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                      }];
    
}

- (void) showRideReceipt: (NSNumber *) rideId amount:(NSNumber *) amount {
  
    
    [UIAlertView showWithTitle:@"Receipt"
                       message:[NSString stringWithFormat:
                                @"Thanks for riding.  We have charged your card for a total of %@",
                                 [VCUtilities formatCurrencyFromCents:amount]]
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil // @[@"Detailed Receipt"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [VCUserStateManager instance].rideProcessState = kUserStateIdle;
                          if (buttonIndex != 0){
                              // Launch the payments page for this ride
                          }
                      }];
}

- (void) showRidePaymentProblem: (NSNumber *) rideId {
    [UIAlertView showWithTitle:@"Payment Problem"
                       message:@"There was a problem processing the payment for your ride.  Voco will contact you to resolve this matter"
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [VCUserStateManager instance].rideProcessState = kUserStateIdle;
                      }];
}


- (void) commuterRideFound: (Ticket *) request {
    [UIAlertView showWithTitle:@"Commuter Ride Found!"
                       message:[NSString stringWithFormat:@"Your requested pick up at %@ has been found.  Would you like to view the details now?", request.desiredArrival]
             cancelButtonTitle:@"Not now"
             otherButtonTitles:@[@"Yes!"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if(buttonIndex == 1){
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"commuter_ride_invoked" object:request userInfo:@{}];

                          }
                      }];
}



- (void) commuteFulfilled {
    
    
    [UIAlertView showWithTitle:@"Commuter Ride Scheduled!" message:@"Your Commute to and from work has been Fulfilled!" cancelButtonTitle:@"Great!" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

- (void) commuteDriverFulfilled {
    [UIAlertView showWithTitle:@"Commuter Drive Scheduled!" message:@"We have found you riders for your commute!" cancelButtonTitle:@"Great!" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //
    }];
}


- (void) commuteUnfulfilled {
    [UIAlertView showWithTitle:@"Commuter Ride Not Successful." message:@"We were unable to fulfill your commute to and from work.  Please try again tomorrow." cancelButtonTitle:@"Okay :(" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //
    }];
}

- (void) commuteDriverUnfulfilled {
    [UIAlertView showWithTitle:@"Commuter Drive Not Successful." message:@"We were unable to find you riders for your commute.  Please try again tomorrow." cancelButtonTitle:@"Okay :(" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //
    }];
}


@end
