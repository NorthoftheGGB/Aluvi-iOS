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

@implementation VCDialogs


+ (void) offerRideToDriver: (Offer *) rideOffer {
    
    NSString * message = [NSString stringWithFormat:@"From: %@, To: %@. Do you want to accept this ride?", rideOffer.meetingPointPlaceName, rideOffer.destinationPlaceName ];
    
    [UIAlertView showWithTitle:[NSString stringWithFormat:@"New ride request %@", rideOffer.ride_id]
                       message:message
             cancelButtonTitle:@"No"
             otherButtonTitles:@[@"Yes"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              NSLog(@"Declined");
                              
                              VCRideDriverAssignment * assignment = [[VCRideDriverAssignment alloc] init];
                              assignment.rideId = rideOffer.ride_id;
                              assignment.driverId = [VCUserState instance].userId;
                              
                              [[RKObjectManager sharedManager] postObject:assignment path:API_POST_RIDE_DECLINED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                  [VCUserState instance].driverState = @"Ride Declined";

                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                  // network error.. what to do?
                                  [WRUtilities criticalError:error];
                              }];

                              
                          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
                              NSLog(@"Accepted");
                              
                              VCRideDriverAssignment * assignment = [[VCRideDriverAssignment alloc] init];
                              assignment.rideId = rideOffer.ride_id;
                              assignment.driverId = [VCUserState instance].userId;
                              
                              [[RKObjectManager sharedManager] postObject:assignment path:API_POST_RIDE_ACCEPTED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                  
                                  // TODO at this point we assume ride is confirmed
                                  // but at a later date we may add a step that waits for the rider to confirm that
                                  // they know about the ride being scheduled (handshake)
                                  [VCUserState instance].driverState = @"Ride Accepted";
                                  
                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                  // network error.. what to do?
                                  [WRUtilities criticalError:error];
                              }];
                              
                          }
                      }];
}


@end
