//
//  VCFancyButton.m
//  Voco
//
//  Created by snacks on 8/13/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCFancyButton.h"
#import "VCStyle.h"


@implementation VCFancyButton

- (void) style {
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = NO;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.shadowColor = [VCStyle drkBlueColor].CGColor;
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    [self setFrame:CGRectMake(0, 0, 150, 33)];
    [self setTitleColor:[VCStyle greyColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:@"Bryant-Regular" size:16.0];

}

- (void)awakeFromNib{
    
    [self style];
    
}

@end
