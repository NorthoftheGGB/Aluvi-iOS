//
//  VCOnboardingSetRouteViewController.m
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingSetRouteViewController.h"
@import AddressBookUI;
#import <Masonry.h>
#import "VCTicketViewController.h"
#import "VCStyle.h"
#import "VCMapConstants.h"
#import "Route.h"
#import "VCButtonSmall.h"

@interface VCOnboardingSetRouteViewController () <VCTicketViewControllerDelegate>

@property(nonatomic) BOOL pickupPointPicked;
@property(nonatomic) BOOL dropOffPointPicked;
@property (strong, nonatomic) IBOutlet UIView *buttonsView;
@property (strong, nonatomic) VCTicketViewController * ticketViewController;
@property (nonatomic) NSInteger editLocationType;
@property (strong, nonatomic) Route * route;
@property (strong, nonatomic) IBOutlet VCButtonSmall *pickupPointButton;
@property (strong, nonatomic) IBOutlet VCButtonSmall *dropOffPointButton;
@property (strong, nonatomic) IBOutlet UISwitch *driverSwitch;
@end

@implementation VCOnboardingSetRouteViewController

- (id)init {
    self = [super init];
    if(self != nil){
        _pickupPointPicked = NO;
        _dropOffPointPicked = NO;
        _route = [[Route alloc] init];
    }
    return self;
}


- (void) viewDidLoad {
    
    [_buttonsView.layer insertSublayer:[self gradientLayer:self.view.frame] atIndex:0];
    _buttonsView.frame = self.view.frame;
    [self.view addSubview:_buttonsView];
    [_buttonsView setNeedsLayout];
    

}

- (CAGradientLayer *) gradientLayer: (CGRect) frame {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(-1, 0.5);
    gradient.endPoint = CGPointMake(3.0, 0.5);
    return gradient;
}


- (void) transitionToTicketViewController: (NSInteger) editLocationType {
    
    _ticketViewController = [[VCTicketViewController alloc] init];
    [self addChildViewController:_ticketViewController];
    _ticketViewController.view.frame = _buttonsView.frame;
    
    [self.view insertSubview:_ticketViewController.view atIndex:0];
  
    [_ticketViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [_ticketViewController.view setNeedsLayout];

    _ticketViewController.delegate = self;
    [_ticketViewController didMoveToParentViewController:self];
    [_ticketViewController placeInEditLocationMode:editLocationType];
   
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = _buttonsView.frame;
        frame.origin.y = -frame.size.height;
        _buttonsView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (IBAction)didTapOnboardingPickupPointButton:(id)sender {
    if(_driverSwitch.on){
        _editLocationType = kPickupZoneType;
    } else {
        _editLocationType = kPreferredPickupPointType;
    }
    [self transitionToTicketViewController: _editLocationType];
}

- (IBAction)didTapOnboardingWorkLocationButton:(id)sender {
    _editLocationType = kWorkType;
    [self transitionToTicketViewController: _editLocationType];
}

- (IBAction)didTapNextButtonUserPhoto:(id)sender {
    if(_route.work == nil || (_route.home == nil && _route.pickupZoneCenter == nil)){
        [UIAlertView showWithTitle:@"Locations" message:@"Please select a pickup point / zone and a work location" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    NSDictionary * values = @{
        RouteObjectValueKey : _route,
        DriverValueKey : [NSNumber numberWithBool: _driverSwitch.on ]
    };
    [self.delegate VCOnboardingChildViewController:self didSetValues:values];
    [self.delegate VCOnboardingChildViewControllerDidFinish:self];
}

- (IBAction)driverSwitchValueChanged:(id)sender {
    UISwitch * driverSwitch = (UISwitch *) sender;
    _route.driving = driverSwitch.on;
}

#pragma delegate
- (void) overrideUpdateLocation:(CLPlacemark*) placemark type:(NSInteger) type {
    
    
    NSString * placeName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
    if(placeName == nil || [placeName isEqualToString:@""]){
        placeName = [placemark.addressDictionary objectForKey:@"Name"];
    }
    if(placeName == nil || [placeName isEqualToString:@""]){
        NSArray * values = [placemark.addressDictionary allValues];
        if([values count] > 0){
            placeName = [values objectAtIndex:0];
        }
    }
    if(placeName == nil || [placeName isEqualToString:@""]){
        placeName = @"My Location";
    }
    switch(type){
        case kPreferredPickupPointType:
        {
            _route.home = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            _route.homePlaceName = placeName;
            _route.pickupZoneCenter = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            _route.pickupZoneCenterPlaceName = placeName;
            [self updateFromButton: _route.homePlaceName];
        }
            break;
        case kWorkType:
        {
            _route.work = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            _route.workPlaceName = placeName;
            [self updateToButton: _route.workPlaceName];
        }
            break;
        case kPickupZoneType:
        {
            _route.home = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            _route.homePlaceName = placeName;
            _route.pickupZoneCenter = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            _route.pickupZoneCenterPlaceName = placeName;
            [self updateFromButton: _route.pickupZoneCenterPlaceName];
        }
            break;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = _buttonsView.frame;
        frame.origin.y = 0;
        _buttonsView.frame = frame;
    } completion:^(BOOL finished) {
        [_ticketViewController.view removeFromSuperview];
        _ticketViewController = nil;

    }];
}

- (void)overrideCancelledUpdateLocation {
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = _buttonsView.frame;
        frame.origin.y = 0;
        _buttonsView.frame = frame;
    } completion:^(BOOL finished) {
        [_ticketViewController.view removeFromSuperview];
        _ticketViewController = nil;
    }];
}

- (void) updateFromButton:(NSString *) addressString{
    NSString * title = [NSString stringWithFormat:@"FROM: %@", addressString];
    [_pickupPointButton setTitle:title forState:UIControlStateNormal];
}

- (void) updatePickupZoneButton:(NSString *) addressString{
    NSString * title = [NSString stringWithFormat:@"Within 2 Miles Of: %@", addressString];
    [_pickupPointButton setTitle:title forState:UIControlStateNormal];
}

- (void) updateToButton:(NSString *) addressString{
    NSString * title = [NSString stringWithFormat:@"TO: %@", addressString];
    [_dropOffPointButton setTitle:title forState:UIControlStateNormal];
}



@end
