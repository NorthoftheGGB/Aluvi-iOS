//
//  VCRideDetailsConfirmationView.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideDetailsConfirmationView.h"

@implementation VCRideDetailsConfirmationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// If Driver

- (void) hideForDriver {
    
    _driverNameLabel;
    _driverPhotoImageView;
    _carTypeLabel;
    _licenseLabel;
    
    
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
