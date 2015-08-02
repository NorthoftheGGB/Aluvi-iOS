//
//  VCRideRequest.h
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
#import "Route.h"

#define VCLOCATIONTYPEHOME 1001
#define VCLOCATIONTYPEWORK 1002

@class VCRideRequestView;

@protocol VCRideRequestViewDelegate <NSObject>

- (void) rideRequestView: (VCRideRequestView *) rideRequestView didTapEditLocation:  (CLLocationCoordinate2D) location locationName:(NSString *) locationName type:(NSInteger) type;
- (void) rideRequestView: (VCRideRequestView *) rideRequestView didTapScheduleCommute:(Route *) route;
- (void) rideRequestViewDidTapClose: (VCRideRequestView *) rideRequestView;

@end

@interface VCRideRequestView : UIView

@property (weak, nonatomic) id<VCRideRequestViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *fromButton;
@property (strong, nonatomic) IBOutlet UIButton *toButton;
@property (strong, nonatomic) IBOutlet UIStepper *toWorkTimeStepper;
@property (strong, nonatomic) IBOutlet UILabel *toWorkTimeLabel;
@property (strong, nonatomic) IBOutlet UIStepper *toHomeTimeStepper;
@property (strong, nonatomic) IBOutlet UILabel *toHomeTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *driverCheckbox;
@property (strong, nonatomic) IBOutlet UIButton *scheduleButton;

- (void) updateLocation:(MKMapItem*) mapItem type:(NSInteger) type;

- (IBAction)didTapCloseButton:(id)sender;
- (IBAction)didTapToWorkTimeStepper:(id)sender;
- (IBAction)didTapToHomeTimeStepper:(id)sender;
- (IBAction)didTapScheduleButton:(id)sender;

@end

//TODO it would be useful for fromButton to retain the 'from'
