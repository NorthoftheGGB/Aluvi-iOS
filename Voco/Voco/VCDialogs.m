//
//  VCDialogs.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDialogs.h"
#import <RestKit.h>
#import "VCRideDriverAssignment.h"
#import "VCUserState.h"
#import "VCDriverApi.h"
#import "NSDate+Pretty.h"

static VCDialogs *sharedSingleton;

@interface VCDialogs ()

@property(nonatomic, strong) UIAlertView * currentAlertView;
@property(nonatomic, strong) Offer * offer;

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
        _offer = nil;
    }
    return self;
}

- (void)offerNextRideToDriver
{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Offer"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"decided = %@", [NSNumber numberWithBool:NO]];
    [request setPredicate:predicate];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    NSError * error;
    NSArray * offers = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
    if([offers count] < 1){
        return;
    }
    
    [VCUserState instance].driveProcessState = @"ride offered";
    [self offerRideToDriver:[offers objectAtIndex:0]];
}

- (void) offerRideToDriver: (Offer *) rideOffer {
    _interfaceState = VC_INTERFACE_STATE_OFFER_DIALOG;
    _offer = rideOffer;
    
    NSString * title = [NSString stringWithFormat:@"Ride requested from: %@, To: %@.", rideOffer.meetingPointPlaceName, rideOffer.dropOffPointPlaceName ];
    
    _currentAlertView = [UIAlertView showWithTitle:title
                                           message:@"Do you want view this ride?"
                                 cancelButtonTitle:@"No"
                                 otherButtonTitles:@[@"Yes"]
                                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                                  
                                                  [VCDriverApi cancelRide:rideOffer.ride_id
                                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                      [VCUserState instance].driveProcessState = @"Ride Declined";
                                                                      [rideOffer markAsDeclined];
                                                                      [VCCoreData saveContext];
                                                                      [self offerNextRideToDriver];
                                                                      _interfaceState = VC_INTERFACE_STATE_IDLE;
                                                                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                      _interfaceState = VC_INTERFACE_STATE_IDLE;
                                                                  }];
                                                  
                                              } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
                                                  
                                                  [VCDriverApi loadDriveDetails:rideOffer.ride_id
                                                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ride_offer_invoked" object:[VCDialogs instance] userInfo:@{@"ride_id" : rideOffer.ride_id }];
                                                                            _interfaceState = VC_INTERFACE_STATE_IDLE;
                                                                        }
                                                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                            _interfaceState = VC_INTERFACE_STATE_IDLE;

                                                                        }];
                                                  
                                                  
                                              }
                                          }];
}

- (void) retractOfferDialog: (NSNumber *) offerId {
    if([_interfaceState isEqualToString:VC_INTERFACE_STATE_OFFER_DIALOG] && [offerId isEqualToNumber: _offer.id]){
        [_currentAlertView dismissWithClickedButtonIndex:-1 animated:YES];
        _offer.decided = [NSNumber numberWithBool:YES];
        NSError * error = nil;
        [[VCCoreData managedObjectContext] save:&error];
        if(error != nil){
            [WRUtilities criticalError:error];
        }
        _offer = nil;
        [VCUserState instance].driveProcessState = kUserStateIdle;
        _interfaceState = VC_INTERFACE_STATE_IDLE;
        [self offerNextRideToDriver];
    }
}

- (void) rideFound: (NSNumber *) requestId {
    [UIAlertView showWithTitle:@"Ride Found!" message:@"Your ride has been scheduled" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    [VCUserState instance].driveProcessState = kUserStateRideScheduled;
}

- (void) rideCancelledByRider {
    [UIAlertView showWithTitle:@"Ride Cancelled!" message:@"The rider cancelled the ride" cancelButtonTitle:@"OK" otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [[VCDialogs instance] offerNextRideToDriver];
                      }];
    
}

- (void) rideCancelledByDriver {
    [UIAlertView showWithTitle:@"Ride Cancelled!" message:@"The driver cancelled the ride."
             cancelButtonTitle:@"OK" otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                      }];
    
}

- (void) showRideReceipt: (NSNumber *) rideId {
    [UIAlertView showWithTitle:@"Receipt"
                       message:@"This is a placeholder for the ride receipt.  Thanks for riding!"
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [VCUserState instance].rideProcessState = kUserStateIdle;
                      }];
}

- (void) commuterRideFound: (Request *) request {
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

- (void) rideAssigned: (Ride *) ride {
    [UIAlertView showWithTitle:@"New Ride Assigned!"
                       message:[NSString stringWithFormat:@"A ride from %@ to %@ at %@ has been assigned to you.  View details now ?",
                                ride.meetingPointPlaceName, ride.dropOffPointPlaceName, [ride.pickupTime pretty]]
             cancelButtonTitle:@"Not Now" otherButtonTitles:@[@"Yes!"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if(buttonIndex == 1){
                               [[NSNotificationCenter defaultCenter] postNotificationName:@"driver_ride_invoked" object:ride userInfo:@{}];
                          }
                      }];
}


@end
