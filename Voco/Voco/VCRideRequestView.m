//
//  VCRideRequest.m
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCRideRequestView.h"

@interface VCRideRequestView ()

// data
@property (strong, nonatomic) NSArray * morningOptions;
@property (strong, nonatomic) NSArray * eveningOptions;

@end

@implementation VCRideRequestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _morningOptions = @[ @"Select Pickup Time",
                             @"7:00", @"7:15", @"7:30", @"7:45",
                             @"8:00", @"8:25", @"8:30", @"8:45", @"9:00"
                             ];
        _eveningOptions = @[
                             @"4:00", @"4:15", @"4:30", @"4:45",
                             @"5:00", @"5:15", @"5:30", @"5:45",
                             @"6:00", @"6:15", @"6:30", @"6:45",
                             @"7:00"];
        
        _toHomeTimeStepper.minimumValue = 0;
        _toHomeTimeStepper.maximumValue = [_eveningOptions count]-1;
        _toHomeTimeStepper.stepValue = 1;
        
        
    }
    return self;
}


- (IBAction)didTapCloseButton:(id)sender {
    [_delegate rideRequestViewDidTapClose:self];
}

- (IBAction)didTapToWorkTimeStepper:(id)sender {
}

- (IBAction)didTapToHomeTimeStepper:(id)sender {
}

- (IBAction)didTapScheduleButton:(id)sender {
}

- (IBAction)didTapFromButton:(id)sender {
    [_delegate rideRequestView:self didTapEditLocation:CLLocationCoordinate2DMake(40, 40) locationName:@"Home"];
}

- (IBAction)didTapToButton:(id)sender {
}



- (IBAction)morningPickupTimeValueChanged:(UIStepper *)sender {
    int value = [sender value];
    _toHomeTimeLabel.text = [_morningOptions objectAtIndex:value];
}



@end
