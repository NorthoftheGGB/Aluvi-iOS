//
//  VCDialogs.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDialogs.h"
#import <RestKit.h>
#import <UIAlertView+Blocks.h>
#import "VCRideDriverAssignment.h"
#import "VCUserState.h"

@implementation VCDialogs

+ (void)offerNextRideToDriver
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
    
    
    [VCUserState instance].driverState = @"ride offered";
    [VCDialogs offerRideToDriver:[offers objectAtIndex:0]];
}

+ (void) offerRideToDriver: (Offer *) rideOffer {
    [VCUserState instance].interfaceState = VC_INTERFACE_STATE_OFFER_DIALOG;

    NSString * message = [NSString stringWithFormat:@"From: %@, To: %@. Do you want to accept this ride?", rideOffer.meetingPointPlaceName, rideOffer.destinationPlaceName ];
    
    [UIAlertView showWithTitle:[NSString stringWithFormat:@"New ride request %@", rideOffer.ride_id]
                       message:message
             cancelButtonTitle:@"No"
             otherButtonTitles:@[@"Yes"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              VCRideDriverAssignment * assignment = [[VCRideDriverAssignment alloc] init];
                              assignment.rideId = rideOffer.ride_id;
                              assignment.driverId = [VCUserState instance].userId;
                              
                              [[RKObjectManager sharedManager] postObject:assignment path:API_POST_RIDE_DECLINED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                  [VCUserState instance].driverState = @"Ride Declined";
                                  
                                  rideOffer.state = @"declined";
                                  rideOffer.decided = [NSNumber numberWithBool:YES];
                                  NSError * error = nil;
                                  [[VCCoreData managedObjectContext] save:&error];
                                  if(error != nil){
                                      [WRUtilities criticalError:error];
                                  }
                                  
                                  [VCUserState instance].interfaceState = VC_INTERFACE_STATE_IDLE;
                                  
                                  [self offerNextRideToDriver];

                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                  
                                  if(operation.HTTPRequestOperation.response.statusCode == 404){
                                      // ride is actually assigned to this driver already, can't be decline
                                      [WRUtilities criticalErrorWithString:@"This ride is already assigned to the logged in driver.  It cannot be decline and must be cancelled instead"];
                                      [VCUserState instance].interfaceState = VC_INTERFACE_STATE_IDLE;

                                  } else if(operation.HTTPRequestOperation.response.statusCode == 403){
                                      // ride isn't available anymore anyway, just continue
                                      [VCUserState instance].interfaceState = VC_INTERFACE_STATE_IDLE;
                                      [VCDialogs offerNextRideToDriver];
                                  } else {
                                      [WRUtilities criticalError:error];
                                      [VCUserState instance].interfaceState = VC_INTERFACE_STATE_IDLE;
                                  }
                              }];

                              
                          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
                              VCRideDriverAssignment * assignment = [[VCRideDriverAssignment alloc] init];
                              assignment.rideId = rideOffer.ride_id;
                              assignment.driverId = [VCUserState instance].userId;
                              
                              [[RKObjectManager sharedManager] postObject:assignment path:API_POST_RIDE_ACCEPTED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                  
                                  // TODO at this point we assume ride is confirmed
                                  // but at a later date we may add a step that waits for the rider to confirm that
                                  // they know about the ride being scheduled (handshake)
                                  [VCUserState instance].driverState = @"Ride Accepted";
                                  
                                  rideOffer.state = @"accepted";
                                  rideOffer.decided = [NSNumber numberWithBool:YES];
                                  NSError * error = nil;
                                  [[VCCoreData managedObjectContext] save:&error];
                                  if(error != nil){
                                      [WRUtilities criticalError:error];
                                  }
                                  [VCUserState instance].interfaceState = VC_INTERFACE_STATE_IDLE;

                                  
                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                  // network error.. what to do?
                                  
                                  if(operation.HTTPRequestOperation.response.statusCode == 403){
                                      // already accepted by another driver
                                      [UIAlertView showWithTitle:@"Ride no longer available!" message:@"Unfortunately another driver beat you too this ride!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                          [VCUserState instance].interfaceState = VC_INTERFACE_STATE_IDLE;
                                          [VCDialogs offerNextRideToDriver];
                                      }];
                                  } else {
                                      //network or server error
                                      [WRUtilities criticalError:error];
                                      [VCUserState instance].interfaceState = VC_INTERFACE_STATE_IDLE;
                                  }
                               
                              }];
                              
                          }
                      }];
}


@end
