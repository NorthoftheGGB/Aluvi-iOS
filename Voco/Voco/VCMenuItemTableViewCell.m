//
//  VCMenuItemTableViewCell.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCMenuItemTableViewCell.h"
#import "VCStyle.h"

@interface VCMenuItemTableViewCell ()



@end

@implementation VCMenuItemTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    

}

- (void) select {
    [_menuItemLabel setFont:[VCStyle boldFont]];
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
}

- (void) deselect {
    [_menuItemLabel setFont:[VCStyle regularFont]];
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
}


@end
