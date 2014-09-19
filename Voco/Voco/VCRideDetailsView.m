//
//  VCRideDetailsConfirmationView.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideDetailsView.h"

@implementation VCRideDetailsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// If Driver

- (void) driverLayout {
    
    _driverNameLabel.hidden = true;
    _driverPhotoImageView.hidden = true;
    _carTypeLabel.hidden = true;
    _licenseLabel.hidden = true;
    _rideTimeLabel = false;
    _rideTimeValueLabel = false;
    _riderSectionTitleLabel.text = [NSString stringWithFormat:@"Your Riders :"];
    self.licenseValueLabel.hidden = false;
    self.carTypeValueLabel.hidden = false;
    
}

- (void) riderDisplay {
    self.licenseValueLabel.hidden = true;
    self.carTypeValueLabel.hidden = true;
}

//If Rider


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)didTapConfirmButton:(id)sender {
}

@end
