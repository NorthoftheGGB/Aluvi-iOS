//
//  VCRideDetailsHudView.h
//  Voco
//
//  Created by Elliott De Aratanha on 7/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCRideDetailsView.h"

@interface VCRideDetailsHudView : VCRideDetailsView
@property (weak, nonatomic) IBOutlet UIImageView *driverImageView;
@property (weak, nonatomic) IBOutlet VCLabelBold *driverFirstNameLabel;
@property (weak, nonatomic) IBOutlet VCLabelBold *driverLastNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *callDriverButton;
- (IBAction)didTapCallDriverButton:(id)sender;

@end
