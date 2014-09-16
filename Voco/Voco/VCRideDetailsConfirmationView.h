//
//  VCRideDetailsConfirmationView.h
//  Voco
//
//  Created by Elliott De Aratanha on 7/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCRideDetailsView.h"

@interface VCRideDetailsConfirmationView : VCRideDetailsView


@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedButton;

@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *confirmButton;

- (IBAction)didTapConfirmButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *driverPhotoImageView;

//Details

@property (weak, nonatomic) IBOutlet VCLabel *pickupTimeLabel;
@property (weak, nonatomic) IBOutlet VCLabel *totalRideTimeLabel;
@property (weak, nonatomic) IBOutlet VCLabelBold *driverNameLabel;

@property (weak, nonatomic) IBOutlet VCLabel *carTypeLabel;

@property (weak, nonatomic) IBOutlet VCLabel *carTypeValueLabel;
@property (weak, nonatomic) IBOutlet VCLabel *licenseValueLabel;


//Riders
@property (weak, nonatomic) IBOutlet VCLabel *riderSectionTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *riderImageView1;

@property (weak, nonatomic) IBOutlet UIImageView *riderImageView2;

@property (weak, nonatomic) IBOutlet UIImageView *riderImageView3;


@property (weak, nonatomic) IBOutlet VCLabel *riderLabel1;
@property (weak, nonatomic) IBOutlet VCLabel *riderLabel2;
@property (weak, nonatomic) IBOutlet VCLabel *riderLabel3;


@end
