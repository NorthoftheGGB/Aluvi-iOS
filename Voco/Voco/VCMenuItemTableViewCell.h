//
//  VCMenuItemTableViewCell.h
//  Voco
//
//  Created by Elliott De Aratanha on 7/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCMenuItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *menuItemLabel;
@property (weak, nonatomic) IBOutlet UIView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *badgeNumberLabel;


- (void) select;

@end
