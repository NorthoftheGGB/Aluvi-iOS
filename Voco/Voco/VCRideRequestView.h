//
//  VCRideRequest.h
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCRideRequestView : UIView

@property (strong, nonatomic) IBOutlet UIButton *fromButton;
@property (strong, nonatomic) IBOutlet UIButton *toButton;
@property (strong, nonatomic) IBOutlet UIStepper *toWorkTimeStepper;
@property (strong, nonatomic) IBOutlet UILabel *toWorkTimeLabel;
@property (strong, nonatomic) IBOutlet UIStepper *toHomeTimeStepper;
@property (strong, nonatomic) IBOutlet UILabel *toHomeTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *driverCheckbox;
@property (strong, nonatomic) IBOutlet UIButton *scheduleButton;


- (IBAction)didTapCloseButton:(id)sender;
- (IBAction)didTapToWorkTimeStepper:(id)sender;
- (IBAction)didTapToHomeTimeStepper:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *didTapDriverCheckbox;
- (IBAction)didTapScheduleButton:(id)sender;

@end

//TODO it would be useful for fromButton to retain the 'from'
