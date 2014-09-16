//
//  VCRideDetailsHudView.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/24/14.
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

- (void) hideCarInfo {
    _licenseValueLabel.hidden = true;
    _carTypeValueLabel.hidden = true;
}

- (void) showCarInfo {
    _licenseValueLabel.hidden = false;
    _carTypeValueLabel.hidden = false;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
