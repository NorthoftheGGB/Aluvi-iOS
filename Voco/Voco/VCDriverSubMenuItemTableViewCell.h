//
//  VCDriverSubMenuItemTableViewCell.h
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLabel.h"


@interface VCDriverSubMenuItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet VCLabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


- (void) select;
- (void) deselect;

@end
