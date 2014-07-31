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

@property (weak, nonatomic) IBOutlet VCLabel *pickupTimeLabel;
@property (weak, nonatomic) IBOutlet VCLabelBold *driverNameLabel;

@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *confirmButton;

@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *didTapConfirmButton;

@end
