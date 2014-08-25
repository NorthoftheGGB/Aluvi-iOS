//
//  VCReceiptExpandedTableViewCell.h
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLabel.h"
#import "VCLabelBold.h"



@interface VCReceiptExpandedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet VCLabel *dateTopLabel;
@property (weak, nonatomic) IBOutlet VCLabel *titleLabel;
@property (weak, nonatomic) IBOutlet VCLabel *dateDetailLabel;
@property (weak, nonatomic) IBOutlet VCLabelBold *totalFareAmountLabel;
@property (weak, nonatomic) IBOutlet VCLabel *rideNumberLabel;
@property (weak, nonatomic) IBOutlet VCLabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet VCLabel *distanceLabel;
@property (weak, nonatomic) IBOutlet VCLabel *directionLabel;

@end
