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

@property (strong, nonatomic) IBOutlet UIButton *fromButton;
@property (strong, nonatomic) IBOutlet UIButton *toButton;
@property (strong, nonatomic) IBOutlet UIStepper *toWorkTimeStepper;
@property (strong, nonatomic) IBOutlet UILabel *toWorkTimeLabel;
@property (strong, nonatomic) IBOutlet UIStepper *toHomeTimeStepper;
@property (strong, nonatomic) IBOutlet UILabel *toHomeTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *driverCheckbox;
@property (strong, nonatomic) IBOutlet UIButton *scheduleButton;


// data
@property (strong, nonatomic) NSArray * morningOptions;
@property (strong, nonatomic) NSArray * eveningOptions;

// state
@property (nonatomic) BOOL commutePreferencesHaveChanged;
@property (nonatomic, strong) Route * route;
@property (nonatomic) BOOL cancelable;

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
    
    _commutePreferencesHaveChanged = NO;

}

- (void) updateWithRoute:(Route *) route {
    _toWorkTimeLabel.text = route.pickupTime;
    _toHomeTimeLabel.text = route.returnTime;
    [self updateFromButton:route.homePlaceName];
    [self updateToButton:route.workPlaceName];
    if(route.driving){
        [_driverCheckbox setSelected:YES];
    } else {
        [_driverCheckbox setSelected:NO];
    }
    _route = [route copy]; // copy, not retain
}

- (void) setEditable:(BOOL) editable {
    if(editable) {
        _fromButton.enabled = YES;
        _toButton.enabled = YES;
        _toHomeTimeStepper.enabled = YES;
        _toWorkTimeStepper.enabled = YES;
        _driverCheckbox.enabled= YES;
        _cancelable = NO;
    } else {
        [_scheduleButton setTitle:@"Cancel Commute" forState:UIControlStateNormal];
        _fromButton.enabled = NO;
        _toButton.enabled = NO;
        _toHomeTimeStepper.enabled = NO;
        _toWorkTimeStepper.enabled = NO;
        _driverCheckbox.enabled= NO;
        _cancelable = YES;
    }
}



- (IBAction)didTapCloseButton:(id)sender {
    if(_commutePreferencesHaveChanged){
        [UIAlertView showWithTitle:@"Save Changes?" message:@"Do you want to save the changes you made to your commute settings?" cancelButtonTitle:@"Nope" otherButtonTitles:@[@"Yes!"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex == 1){
                [_delegate rideRequestViewDidTapClose:self withChanges:_route];
            }
        }];
        _commutePreferencesHaveChanged = NO;
    } else {
        [_delegate rideRequestViewDidCancel:self];
    }
}


- (IBAction)didTapScheduleButton:(id)sender {
    if(_cancelable){
        [_delegate rideRequestViewDidCancelCommute:self];
    } else {
        [_delegate rideRequestView:self didTapScheduleCommute:_route];
    }
    _commutePreferencesHaveChanged = NO;

}

- (IBAction)didTapFromButton:(id)sender {
    [_delegate rideRequestView:self didTapEditLocation:CLLocationCoordinate2DMake(40, 40) locationName:@"Home" type:kHomeType];
}

- (IBAction)didTapToButton:(id)sender {
    [_delegate rideRequestView:self didTapEditLocation:CLLocationCoordinate2DMake(40, 40) locationName:@"Work" type:kWorkType];
}



- (IBAction)morningPickupTimeValueChanged:(UIStepper *)sender {
    int value = [sender value];
    NSString * time = [_morningOptions objectAtIndex:value];
    _toWorkTimeLabel.text = time;
    _commutePreferencesHaveChanged = YES;
    _route.pickupTime = time;
}
- (IBAction)eveningPickupValueChanged:(UIStepper *)sender {
    int value = [sender value];
    NSString * time = [_eveningOptions objectAtIndex:value];
    _toHomeTimeLabel.text = time;
    _commutePreferencesHaveChanged = YES;
    _route.returnTime = time;
}

- (void) updateLocation:(MKPlacemark*) placemark type:(NSInteger) type {
    switch (type) {
        case kHomeType:
        {
            _route.home = [[CLLocation alloc] initWithLatitude:placemark.coordinate.latitude longitude:placemark.coordinate.longitude];
            _route.homePlaceName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            [self updateFromButton: _route.homePlaceName];
            _commutePreferencesHaveChanged = YES;
        }
            break;
        case kWorkType:
        {
            _route.work = [[CLLocation alloc] initWithLatitude:placemark.coordinate.latitude longitude:placemark.coordinate.longitude];
            _route.workPlaceName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            [self updateToButton:_route.workPlaceName];
            _commutePreferencesHaveChanged = YES;
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
