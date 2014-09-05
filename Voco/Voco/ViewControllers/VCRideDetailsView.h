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


@interface VCRideDetailsView : UIView

//details


@property (weak, nonatomic) IBOutlet UIImageView *creditCardImageView;
@property (weak, nonatomic) IBOutlet VCLabel *cardNicknamelabel;
@property (weak, nonatomic) IBOutlet VCLabel *cardNumberLabel;

@property (weak, nonatomic) IBOutlet VCLabelBold *fareLabel;
@property (weak, nonatomic) IBOutlet VCLabel *licenseLabel;
@property (weak, nonatomic) IBOutlet VCLabel *carTypeLabel;

@end
