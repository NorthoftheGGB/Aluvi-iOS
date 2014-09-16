//
//  VCSubMenuItemTableViewCell.h
//  Voco
//
//  Created by Elliott De Aratanha on 8/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLabel.h"


@interface VCSubMenuItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet VCLabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet VCLabel *itemDateLabel;
@property (weak, nonatomic) IBOutlet VCLabel *itemTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


- (void) select;
- (void) deselect;

@end
