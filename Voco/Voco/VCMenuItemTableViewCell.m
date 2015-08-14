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


@property (nonatomic) BOOL disabled;
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

- (void) setDisabled: (BOOL) disabled {
    if(disabled) {
        self.contentView.alpha = .5;
        _disabled = YES;
    } else {
        self.contentView.alpha = 1;
        _disabled = NO;
    }
    
}

- (BOOL) isDisabled {
    return _disabled;
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
