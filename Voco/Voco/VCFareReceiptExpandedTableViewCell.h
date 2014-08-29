    //
//  VCFareReceiptExpandedTableViewCell.h
//  Voco
//
//  Created by Elliott De Aratanha on 8/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLabel.h"
#import "VCLabelBold.h"



@interface VCFareReceiptExpandedTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView * collapsed;
@property (strong, nonatomic) IBOutlet UIView * expanded;
@property (weak, nonatomic) IBOutlet VCLabel *dateLabelCollapsed;
@property (weak, nonatomic) IBOutlet VCLabel *titleLabelCollapsed;
@property (weak, nonatomic) IBOutlet VCLabel *dateLabel;
@property (weak, nonatomic) IBOutlet VCLabel *titleLabel;
@property (weak, nonatomic) IBOutlet VCLabel *dateDetailLabel;
@property (weak, nonatomic) IBOutlet VCLabelBold *totalFareAmountLabel;
@property (weak, nonatomic) IBOutlet VCLabel *rideNumberLabel;
@property (weak, nonatomic) IBOutlet VCLabel *riderNameOneLabel;
@property (weak, nonatomic) IBOutlet VCLabel *riderNameTwoLabel;
@property (weak, nonatomic) IBOutlet VCLabel *riderNameThreeLabel;

@property (weak, nonatomic) IBOutlet VCLabel *distanceLabel;
@property (weak, nonatomic) IBOutlet VCLabel *directionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *downArrowImageView;
@end
