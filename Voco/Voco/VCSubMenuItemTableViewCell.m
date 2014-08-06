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
}

- (void) deselect {
    self.backgroundImageView.image = [UIImage imageNamed:@"menu-item-bg"];
}

@end
