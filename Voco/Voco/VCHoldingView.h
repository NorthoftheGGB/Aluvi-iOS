//
//  VCHoldingView.h
//  Voco
//
//  Created by Matthew Shultz on 9/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCButtonStandardStyle.h"
#import "VCLabel.h"
#import "Ticket.h"

@interface VCHoldingView : UIView

@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *showRideDetailsButton;
@property (weak, nonatomic) IBOutlet VCLabel *rideRequestStatusLabel;
@property (weak, nonatomic) IBOutlet VCLabel *rideRequestDetailLabel;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *okButton;

- (void) resetView;
- (void) transitionToRideRequestApproved:(Ticket *) ticket;
- (void) transitionToRideRequestDenied;

@end
