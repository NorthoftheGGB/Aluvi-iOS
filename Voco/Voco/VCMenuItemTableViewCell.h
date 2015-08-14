//
//  VCMenuItemTableViewCell.h
//  Voco
//
//  Created by Elliott De Aratanha on 7/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCMenuItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *menuItemLabel;


- (void) setDisabled: (BOOL) disabled;
- (BOOL) isDisabled;

- (void) select;
- (void) deselect;

@end
