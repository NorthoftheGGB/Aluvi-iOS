//
//  VCMenuUserInfoTableViewCell.h
//  Voco
//
//  Created by Elliott De Aratanha on 8/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCButton.h"
#import "VCLabelBold.h"

@interface VCMenuUserInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet VCLabelBold *userFullName;


@property (weak, nonatomic) IBOutlet VCButton *logoutButton;
- (IBAction)didTapLogout:(id)sender;


@end
