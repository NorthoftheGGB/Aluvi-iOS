//
//  VCDriveDetailsView.h
//  Voco
//
//  Created by Elliott De Aratanha on 8/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLabel.h"
#import "VCLabelBold.h"
#import "VCButtonStandardStyle.h"



@interface VCDriveDetailsView : UIView
@property (weak, nonatomic) IBOutlet VCLabel *dateLabel;
@property (weak, nonatomic) IBOutlet VCLabelBold *fareEarningsLabel;
@property (weak, nonatomic) IBOutlet VCLabel *driveTimeLabel;
@property (weak, nonatomic) IBOutlet VCLabel *driveDistanceLabel;
@property (weak, nonatomic) IBOutlet VCLabel *numberOfPeopleLabel;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *confirmationButton;
- (IBAction)didTapConfirmationButton:(id)sender;

@end
