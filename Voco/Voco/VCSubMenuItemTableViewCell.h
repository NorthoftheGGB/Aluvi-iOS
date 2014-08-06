//
//  VCSubMenuItemTableViewCell.h
//  Voco
//
//  Created by Elliott De Aratanha on 8/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCSubMenuItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


- (void) select;
- (void) deselect;

@end
