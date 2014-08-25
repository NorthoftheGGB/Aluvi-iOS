//
//  VCReceiptTableViewCell.h
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLabel.h"


@interface VCReceiptTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet VCLabel *dateLabel;
@property (weak, nonatomic) IBOutlet VCLabel *titleLabel;

@end
