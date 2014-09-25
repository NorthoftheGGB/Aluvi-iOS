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
    self.itemTitleLabel.textColor = [UIColor colorWithRed:(182/255.f) green:(31/255.f) blue:(36/255.f) alpha:1.0];
    self.itemTimeLabel.textColor = [UIColor colorWithRed:(182/255.f) green:(31/255.f) blue:(36/255.f) alpha:1.0];
    self.itemDateLabel.textColor = [UIColor colorWithRed:(182/255.f) green:(31/255.f) blue:(36/255.f) alpha:1.0];
}

- (void) deselect {
    self.backgroundImageView.image = [UIImage imageNamed:@"menu-item-bg-select"];
    self.arrowImageView.image = [UIImage imageNamed:@"menu-submenu-arrow"];
    self.itemTitleLabel.textColor = [UIColor colorWithRed:(162/255.f) green:(148/255.f) blue:(144/255.f) alpha:1.0];
    self.itemTimeLabel.textColor = [UIColor colorWithRed:(162/255.f) green:(148/255.f) blue:(144/255.f) alpha:1.0];
    self.itemDateLabel.textColor = [UIColor colorWithRed:(162/255.f) green:(148/255.f) blue:(144/255.f) alpha:1.0];
}

//badged
//highlighted

@end
