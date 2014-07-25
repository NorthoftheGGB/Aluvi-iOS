//
//  VCRideDetailsHudView.h
//  Voco
//
//  Created by Elliott De Aratanha on 7/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLabel.h"
#import "VCLabelBold.h"
#import "VCButtonStandardStyle.h"


@interface VCRideDetailsHudView : UIView

//details

@property (weak, nonatomic) IBOutlet VCLabelBold *driverNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *creditCardImageView;
@property (weak, nonatomic) IBOutlet VCLabel *cardNicknamelabel;
@property (weak, nonatomic) IBOutlet VCLabel *cardNumberLabel;

@property (weak, nonatomic) IBOutlet VCLabelBold *fareLabel;
@property (weak, nonatomic) IBOutlet VCLabel *pickupTimeLabel;
@property (weak, nonatomic) IBOutlet VCLabel *liscenceLabel;
@property (weak, nonatomic) IBOutlet VCLabel *carTypeLabel;





@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *confirmButton;

- (IBAction)didTapConfirm:(id)sender;

@end
