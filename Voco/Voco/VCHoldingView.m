//
//  VCHoldingView.m
//  Voco
//
//  Created by Matthew Shultz on 9/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCHoldingView.h"

@implementation VCHoldingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) resetView {
    _okButton.hidden = YES;
    _showRideDetailsButton.hidden = YES;
    _rideRequestStatusLabel.text = @"Your ride to and from work will be ready at 9:30pm!";
    _rideRequestDetailLabel.text = @"Sometimes the pickup points require walking or driving to get to. Make sure you leave yourself enough time to be at the pickup point at the designated time.";
}

/*
 Confirmation Screen: Ride Request Approved
 
 - Show “showRideDetailsButton”
 - rideRequestStatusLabel - change text string to: "Your ride to and from work is ready!"
 
 didTapShowRideDetailsButton ==> takes you to Ride Details*/

- (void) transitionToRideRequestApproved:(Ticket *) ticket {
    if([ticket.driving boolValue]) {
        _rideRequestStatusLabel.text = [NSString stringWithFormat:@"Your driving details are ready!"];
        _rideRequestDetailLabel.text = @"";
    } else {
        _rideRequestStatusLabel.text = [NSString stringWithFormat:@"Your ride to and from work is ready!"];
    }
    _showRideDetailsButton.hidden = NO;
}

/*
 Confirmation Screen: Ride Request Denied
 
 - rideRequestStatusLabel - change text string to: “Sorry, we were unable to fulfill your ride request."
 - rideRequestDetailLabel - change text string to: “Would you like to try again for the next day?"
 
 - Show okButton
 - didTapOK - takes you back to the map with edit commute button. */

- (void) transitionToRideRequestDenied{
    _rideRequestStatusLabel.text = [NSString stringWithFormat:@"Sorry, we were unable to fulfill your ride request."];
    _rideRequestDetailLabel.text = [NSString stringWithFormat:@"If you would like to schedule a commute for the following day, please try again tomorrow."];
    _okButton.hidden = NO;
    
}


@end
