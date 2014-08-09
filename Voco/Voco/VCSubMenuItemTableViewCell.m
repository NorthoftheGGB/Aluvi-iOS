//
//  VCSubMenuItemTableViewCell.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCSubMenuItemTableViewCell.h"

@implementation VCSubMenuItemTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) select {
    self.backgroundImageView.image = [UIImage imageNamed:@"menu-item-bg-select"];
    self.arrowImageView.image = [UIImage imageNamed:@"menu-submenu-arrow-select"];
    self.itemTitleLabel.textColor = [UIColor colorWithRed:182 green:31 blue:36 alpha:1.0];
    self.itemTimeLabel.textColor = [UIColor colorWithRed:182 green:31 blue:36 alpha:1.0];
    self.itemDateLabel.textColor = [UIColor colorWithRed:182 green:31 blue:36 alpha:1.0];
}

- (void) deselect {
    self.backgroundImageView.image = [UIImage imageNamed:@"menu-item-bg-select"];
}

@end
