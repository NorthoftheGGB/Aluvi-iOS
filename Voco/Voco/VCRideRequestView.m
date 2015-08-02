//
//  VCRideRequest.m
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCRideRequestView.h"
@import AddressBookUI;

@interface VCRideRequestView ()

// data
@property (strong, nonatomic) NSArray * morningOptions;
@property (strong, nonatomic) NSArray * eveningOptions;

@end

@implementation VCRideRequestView



-(void)awakeFromNib{
    
    _morningOptions = @[
                        @"7:00", @"7:15", @"7:30", @"7:45",
                        @"8:00", @"8:15", @"8:30", @"8:45", @"9:00"
                        ];
    _eveningOptions = @[
                        @"4:00", @"4:15", @"4:30", @"4:45",
                        @"5:00", @"5:15", @"5:30", @"5:45",
                        @"6:00", @"6:15", @"6:30", @"6:45",
                        @"7:00"];
    
    _toHomeTimeLabel.text = [_eveningOptions objectAtIndex:0];
    _toHomeTimeStepper.minimumValue = 0;
    _toHomeTimeStepper.maximumValue = [_eveningOptions count]-1;
    _toHomeTimeStepper.stepValue = 1;
    
    _toWorkTimeLabel.text = [_morningOptions objectAtIndex:0];
    _toWorkTimeStepper.minimumValue = 0;
    _toWorkTimeStepper.maximumValue = [_morningOptions count]-1;
    _toWorkTimeStepper.stepValue = 1;
    


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
    [_delegate rideRequestView:self didTapEditLocation:CLLocationCoordinate2DMake(40, 40) locationName:@"Home" type:kHomeType];
}

- (IBAction)didTapToButton:(id)sender {
    [_delegate rideRequestView:self didTapEditLocation:CLLocationCoordinate2DMake(40, 40) locationName:@"Work" type:kWorkType];
}



- (IBAction)morningPickupTimeValueChanged:(UIStepper *)sender {
    int value = [sender value];
    _toWorkTimeLabel.text = [_morningOptions objectAtIndex:value];
}
- (IBAction)eveningPickupValueChanged:(UIStepper *)sender {
    int value = [sender value];
    _toHomeTimeLabel.text = [_eveningOptions objectAtIndex:value];
}

- (void) updateLocation:(MKPlacemark*) placemark type:(NSInteger) type {
    switch (type) {
        case kHomeType:
        {
            [self updateFromButton:ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)];
        }
            break;
        case kWorkType:
        {
            [self updateToButton:ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)];
        }
            break;
            
        default:
            break;
    }
}


- (void) updateFromButton:(NSString *) addressString{
    NSString * title = [NSString stringWithFormat:@"From: %@", addressString];
    [_fromButton setTitle:title forState:UIControlStateNormal];
}

- (void) updateToButton:(NSString *) addressString{
    NSString * title = [NSString stringWithFormat:@"To: %@", addressString];
    [_toButton setTitle:title forState:UIControlStateNormal];
}



@end
