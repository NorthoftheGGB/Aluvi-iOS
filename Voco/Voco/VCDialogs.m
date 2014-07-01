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

    NSString * title = [NSString stringWithFormat:@"Ride requested from: %@, To: %@.", rideOffer.meetingPointPlaceName, rideOffer.destinationPlaceName ];
    
    _currentAlertView = [UIAlertView showWithTitle:title
                       message:@"Do you want view this ride?"
             cancelButtonTitle:@"No"
             otherButtonTitles:@[@"Yes"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              VCRideDriverAssignment * assignment = [[VCRideDriverAssignment alloc] init];
                              assignment.rideId = rideOffer.ride_id;
                              
                              [[RKObjectManager sharedManager] postObject:assignment path:API_POST_RIDE_DECLINED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                  [VCUserState instance].driveProcessState = @"Ride Declined";
                                  
                                  rideOffer.state = @"declined";
                                  rideOffer.decided = [NSNumber numberWithBool:YES];
                                  NSError * error = nil;
                                  [[VCCoreData managedObjectContext] save:&error];
                                  if(error != nil){
                                      [WRUtilities criticalError:error];
                                  }
                                  
                                  _interfaceState = VC_INTERFACE_STATE_IDLE;
                                  
                                  [self offerNextRideToDriver];

                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                  
                                  if(operation.HTTPRequestOperation.response.statusCode == 404){
                                      // ride is actually assigned to this driver already, can't be decline
                                      [WRUtilities criticalErrorWithString:@"This ride is already assigned to the logged in driver.  It cannot be declined and must be cancelled instead"];
                                      _interfaceState = VC_INTERFACE_STATE_IDLE;

                                  } else if(operation.HTTPRequestOperation.response.statusCode == 403){
                                      // ride isn't available anymore anyway, just continue
                                      rideOffer.decided = [NSNumber numberWithBool:YES];
                                      NSError * error = nil;
                                      [[VCCoreData managedObjectContext] save:&error];
                                      if(error != nil){
                                          [WRUtilities criticalError:error];
                                      }
                                      _interfaceState = VC_INTERFACE_STATE_IDLE;
                                      [self offerNextRideToDriver];
                                  } else {
                                      [WRUtilities criticalError:error];
                                      _interfaceState = VC_INTERFACE_STATE_IDLE;
                                  }
                              }];

                              
                          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
                              
                              
                              
                              /*
                              VCRideDriverAssignment * assignment = [[VCRideDriverAssignment alloc] init];
                              assignment.rideId = rideOffer.ride_id;
                              
                              CLS_LOG(@"%@", @"API_POST_RIDE_ACCEPTED");
                              [[RKObjectManager sharedManager] postObject:assignment path:API_POST_RIDE_ACCEPTED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                  
                                  // TODO at this point we assume ride is confirmed
                                  // but at a later date we may add a step that waits for the rider to confirm that
                                  // they know about the ride being scheduled (handshake)
                                  [VCUserState instance].driveProcessState = kUserStateRideAccepted;
                                  [VCUserState instance].underwayRideId = rideOffer.ride_id;
                                  
                                  rideOffer.state = @"accepted";
                                  rideOffer.decided = [NSNumber numberWithBool:YES];
                                  NSError * error = nil;
                                  [[VCCoreData managedObjectContext] save:&error];
                                  if(error != nil){
                                      [WRUtilities criticalError:error];
                                  }
                                  _interfaceState = VC_INTERFACE_STATE_IDLE;

                                  
                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                  // network error..
                                  
                                  if(operation.HTTPRequestOperation.response.statusCode == 403){
                                      // already accepted by another driver
                                      [UIAlertView showWithTitle:@"Ride no longer available!" message:@"Unfortunately another driver beat you to this ride!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                          _interfaceState = VC_INTERFACE_STATE_IDLE;
                                          rideOffer.decided = [NSNumber numberWithBool:YES];
                                          NSError * error = nil;
                                          [[VCCoreData managedObjectContext] save:&error];
                                          if(error != nil){
                                              [WRUtilities criticalError:error];
                                          }
                                          
                                          [self offerNextRideToDriver];
                                      }];
                                  } else {
                                      //network or server error
                                      [WRUtilities criticalError:error];
                                      _interfaceState = VC_INTERFACE_STATE_IDLE;
                                  }
                               
                              }];
                               */
                              
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

@end
