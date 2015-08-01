//
//  VCRideRequest.m
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCRideRequestView.h"

@implementation VCRideRequestView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)didTapCloseButton:(id)sender {
    [_delegate rideRequestViewDidTapClose:self];
}

- (IBAction)didTapToWorkTimeStepper:(id)sender {
}

- (IBAction)didTapToHomeTimeStepper:(id)sender {
}

- (IBAction)didTapScheduleButton:(id)sender {
}
@end
