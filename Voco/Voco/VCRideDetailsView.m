//
//  VCRideDetailsConfirmationView.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideDetailsView.h"
#import "NSDate+Pretty.h"
#import "Rider.h"
#import "Fare.h"
#import "Driver.h"
#import "Car.h"
#import "VCUtilities.h"
#import "VCUserStateManager.h"

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

- (void) driverLayout:(Ticket *) ticket {
    
    _driverPhotoImageView.hidden = YES;
    _driverNameLabel.hidden = YES;
    _carTypeLabel.hidden = YES;
    _licenseLabel.hidden = YES;
    self.carTypeValueLabel.hidden = YES;
    
    self.licenseValueLabel.hidden = YES;
    self.cardNicknamelabel.hidden = YES;
    self.cardNumberLabel.hidden = YES;
    _rideTimeLabel.hidden = YES;        // We do not have data for total ride time
    _rideTimeValueLabel.hidden = YES;   // We do not have data for total ride time
    _riderSectionTitleLabel.text = @"Your Riders";
    
    _pickupTimeLabel.text = [ticket.pickupTime time];
    self.fareLabel.text = [VCUtilities formatCurrencyFromCents:ticket.hovFare.estimatedEarnings];
    
    
    NSArray * riderNameLabels = @[_riderFirstNameLabel1, _riderFirstNameLabel2, _riderFirstNameLabel3];
    NSArray * riderImageViews = @[_riderImageView1, _riderImageView2, _riderImageView3];
    
    for(int i = 0; i<3; i++){
        ((UILabel *) [riderNameLabels objectAtIndex:i]).text= @"";
    }
    long count = [ticket.hovFare.riders count];
    int i = 0;
    NSArray * riders = [ticket.hovFare.riders allObjects];
    for(; i<count; i++){
        Rider * rider = [riders objectAtIndex:i];
        UILabel * label = ((UILabel *) [riderNameLabels objectAtIndex:i]);
        label.text = rider.firstName;
    }
}

- (void) riderLayout:(Ticket *) ticket {
    _driverPhotoImageView.hidden = NO;
    _driverNameLabel.hidden = NO;
    _carTypeLabel.hidden = NO;
    _licenseLabel.hidden = NO;
    self.carTypeValueLabel.hidden = NO;
    self.licenseValueLabel.hidden = NO;
    self.cardNicknamelabel.hidden = NO;
    self.cardNumberLabel.hidden = NO;
    _rideTimeLabel.hidden = YES;
    _rideTimeValueLabel.hidden = YES;
    _riderSectionTitleLabel.text = @"Fellow Riders";
    _riderSectionTitleLabel.text = [NSString stringWithFormat:@"Fellow Riders :"];

    _pickupTimeLabel.text = [ticket.pickupTime time];
    _driverNameLabel.text = [ticket.driver fullName];
    self.carTypeValueLabel.text = [ticket.car summary];
    self.licenseValueLabel.text = ticket.car.licensePlate;
    self.fareLabel.text = [VCUtilities formatCurrencyFromCents:ticket.fixedPrice];
    self.cardNicknamelabel.text = [VCUserStateManager instance].profile.cardBrand;
    self.cardNumberLabel.text = [VCUserStateManager instance].profile.cardLastFour;

    NSArray * riderNameLabels = @[_riderFirstNameLabel1, _riderFirstNameLabel2, _riderFirstNameLabel3];
    for(int i = 0; i<3; i++){
        ((UILabel *) [riderNameLabels objectAtIndex:i]).text= @"";
    }
}


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
