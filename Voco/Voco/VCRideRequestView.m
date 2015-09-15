//
//  VCRideRequest.m
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCRideRequestView.h"
@import AddressBookUI;
#import "VCUserStateManager.h"
#import <Masonry.h>
#import "VCMapConstants.h"
#import "VCStyle.h"

@interface VCRideRequestView ()

@property (strong, nonatomic) IBOutlet UIButton *fromButton;
@property (strong, nonatomic) IBOutlet UIButton *toButton;
@property (strong, nonatomic) IBOutlet UIStepper *toWorkTimeStepper;
@property (strong, nonatomic) IBOutlet UILabel *toWorkTimeLabel;
@property (strong, nonatomic) IBOutlet UIStepper *toHomeTimeStepper;
@property (strong, nonatomic) IBOutlet UILabel *toHomeTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *scheduleButton;
@property (strong, nonatomic) IBOutlet UILabel *driverCheckboxLabel;
@property (strong, nonatomic) IBOutlet UISwitch *drivingSwitch;
@property (strong, nonatomic) IBOutlet UIButton *pickupZonebutton;
@property (strong, nonatomic) IBOutlet UIView *originView;


// data
@property (strong, nonatomic) NSArray * morningOptions;
@property (strong, nonatomic) NSArray * eveningOptions;

// state
@property (nonatomic) BOOL commutePreferencesHaveChanged;
@property (nonatomic, strong) Route * route;
@property (nonatomic) BOOL cancelable;

@end

@implementation VCRideRequestView



- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.layer insertSublayer:gradient atIndex:0];
}


-(void)awakeFromNib{
    
    [self setGradient];
    
    _morningOptions = @[
                        @"5:00", @"5:15", @"5:30", @"5:45",
                        @"6:00", @"6:15", @"6:30", @"6:45",
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
    
    [_drivingSwitch setOn:[[VCUserStateManager instance] isHovDriver]];
    
}





- (void) updateWithRoute:(Route *) route {
   
    if(route != nil){
        _route = [route copy];
    } else {
        _route = [[Route alloc] init];
    }
    if(route.pickupTime != nil) {
        _toWorkTimeLabel.text = route.pickupTime;
        NSInteger value = [_morningOptions indexOfObject:route.pickupTime];
        _toWorkTimeStepper.value = value;
    }
    if(route.returnTime != nil) {
        _toHomeTimeLabel.text = route.returnTime;
        NSInteger value = [_eveningOptions indexOfObject:route.returnTime];
        [_toHomeTimeStepper setValue:value];
    }
    [self updateFromButton:route.homePlaceName];
    [self updateToButton:route.workPlaceName];
    [self updatePickupZoneButton:route.pickupZoneCenterPlaceName];
    [_drivingSwitch setOn:route.driving];
    [self updateInterfaceForDriving: route.driving];

}

- (void) setEditable:(BOOL) editable {
    if(editable) {
        [_scheduleButton setTitle:@"COMMUTE TOMORROW" forState:UIControlStateNormal];
        _fromButton.enabled = YES;
        _toButton.enabled = YES;
        _pickupZonebutton.enabled = YES;
        _toHomeTimeStepper.enabled = YES;
        _toWorkTimeStepper.enabled = YES;
        _drivingSwitch.enabled= YES;
        _cancelable = NO;
    } else {
        [_scheduleButton setTitle:@"CANCEL COMMUTE" forState:UIControlStateNormal];
        _fromButton.enabled = NO;
        _toButton.enabled = NO;
        _pickupZonebutton.enabled = NO;
        _toHomeTimeStepper.enabled = NO;
        _toWorkTimeStepper.enabled = NO;
        _drivingSwitch.enabled= NO;
        _cancelable = YES;
    }
}

- (void) updateInterfaceForDriving:(BOOL) driving {
    if(driving){
        [_fromButton removeFromSuperview];
        
        [_originView addSubview:_pickupZonebutton];
        
        [_pickupZonebutton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_originView.mas_right);
            make.top.equalTo(_originView.mas_top);
            make.bottom.equalTo(_originView.mas_bottom);
            make.width.mas_equalTo(_originView.frame.size.width);
        }];
        [_pickupZonebutton layoutIfNeeded];
        
        [UIView animateWithDuration:.3 animations:^{
            [_pickupZonebutton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_originView.mas_left);
                make.top.equalTo(_originView.mas_top);
                make.right.equalTo(_originView.mas_right);
                make.bottom.equalTo(_originView.mas_bottom);
            }];
            [_pickupZonebutton layoutIfNeeded];

        } completion:^(BOOL finished) {
            [_fromButton removeFromSuperview];
        }];
        
    } else {
        [_pickupZonebutton removeFromSuperview];
        
        [_originView addSubview:_fromButton];
        
        [_fromButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_originView.mas_right);
            make.top.equalTo(_originView.mas_top);
            make.bottom.equalTo(_originView.mas_bottom);
            make.width.mas_equalTo(_originView.frame.size.width);
        }];
        [_fromButton layoutIfNeeded];

        [UIView animateWithDuration:.3 animations:^{
            [_fromButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_originView.mas_left);
                make.top.equalTo(_originView.mas_top);
                make.right.equalTo(_originView.mas_right);
                make.bottom.equalTo(_originView.mas_bottom);
            }];
            [_fromButton layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            [_pickupZonebutton removeFromSuperview];
        }];
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
    [self updatePickupTime];
    if(_route.pickupTime == nil){
        [UIAlertView showWithTitle:@"Required Field" message:@"Pickup Time is Required" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    [self updateReturnTime];
    if(_route.returnTime == nil){
        [UIAlertView showWithTitle:@"Required Field" message:@"Return Time is Required" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    if(_route.driving){
        if(_route.pickupZoneCenter == nil){
            [UIAlertView showWithTitle:@"Required Field" message:@"Pickup Zone is Required" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            return;
        }
    } else {
        if(_route.home == nil){
            [UIAlertView showWithTitle:@"Required Field" message:@"Pickup Location is Required" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            return;
        }
    }
    if(_route.work == nil){
        [UIAlertView showWithTitle:@"Required Field" message:@"Work Location is Required" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    
    if(_cancelable){
        [_delegate rideRequestViewDidCancelCommute:self];
    } else {
        [_delegate rideRequestView:self didTapScheduleCommute:_route];
    }
    _commutePreferencesHaveChanged = NO;

}

- (IBAction)didTapFromButton:(id)sender {
    [_delegate rideRequestView:self didTapEditLocation:CLLocationCoordinate2DMake(_route.home.coordinate.latitude, _route.home.coordinate.longitude) locationName:@"Home" type:kHomeType];
}

- (IBAction)didTapToButton:(id)sender {
    [_delegate rideRequestView:self didTapEditLocation:CLLocationCoordinate2DMake(_route.work.coordinate.latitude, _route.work.coordinate.longitude) locationName:@"Work" type:kWorkType];
}

- (IBAction)didTapPickupZoneButton:(id)sender {
    [_delegate rideRequestView:self didTapEditLocation:CLLocationCoordinate2DMake(_route.pickupZoneCenter.coordinate.latitude, _route.pickupZoneCenter.coordinate.longitude) locationName:@"Pickup Zone" type:kPickupZoneType];
}


- (IBAction)drivingSwitchValueDidChange:(id)sender {
    _route.driving = _drivingSwitch.on;
    _commutePreferencesHaveChanged = YES;
    
    // Check if they are set up as a driver / rider
    // set switch back if they don't enter the proper data
    
    [self updateInterfaceForDriving:_drivingSwitch.on];
}

- (void) updatePickupTime {
    int value = [_toWorkTimeStepper value];
    NSString * time = [_morningOptions objectAtIndex:value];
    _toWorkTimeLabel.text = time;
    _commutePreferencesHaveChanged = YES;
    _route.pickupTime = time;
}

- (IBAction)morningPickupTimeValueChanged:(UIStepper *)sender {
    [self updatePickupTime];
}

- (void) updateReturnTime {
    int value = [_toHomeTimeStepper value];
    NSString * time = [_eveningOptions objectAtIndex:value];
    _toHomeTimeLabel.text = time;
    _commutePreferencesHaveChanged = YES;
    _route.returnTime = time;
}
- (IBAction)eveningPickupValueChanged:(UIStepper *)sender {
    [self updateReturnTime];
}

- (void) updateLocation:(CLPlacemark*) placemark type:(NSInteger) type {
    switch (type) {
        case kHomeType:
        {
            _route.home = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            _route.homePlaceName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            [self updateFromButton: _route.homePlaceName];
            _commutePreferencesHaveChanged = YES;
        }
            break;
        case kWorkType:
        {
            _route.work = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            _route.workPlaceName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            [self updateToButton:_route.workPlaceName];
            _commutePreferencesHaveChanged = YES;
        }
            break;
        case kPickupZoneType:
            _route.pickupZoneCenter = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            _route.pickupZoneCenterPlaceName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            [self updatePickupZoneButton:_route.pickupZoneCenterPlaceName];
            _commutePreferencesHaveChanged = YES;
            break;
            
        default:
            break;
    }
}


- (void) updateFromButton:(NSString *) addressString{
    NSString * title = [NSString stringWithFormat:@"FROM: %@", addressString];
    [_fromButton setTitle:title forState:UIControlStateNormal];
}

- (void) updatePickupZoneButton:(NSString *) addressString{
    NSString * title = [NSString stringWithFormat:@"Within 2 Miles Of: %@", addressString];
    [_pickupZonebutton setTitle:title forState:UIControlStateNormal];
}

- (void) updateToButton:(NSString *) addressString{
    NSString * title = [NSString stringWithFormat:@"TO: %@", addressString];
    [_toButton setTitle:title forState:UIControlStateNormal];
}



@end
