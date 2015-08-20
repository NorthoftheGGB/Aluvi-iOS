//
//  VCLabelExtraBold.m
//  Voco
//
//  Created by snacks on 8/17/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCLabelExtraBold.h"

@implementation VCLabelExtraBold


- (void)awakeFromNib{
    UIFont *customFont = [UIFont fontWithName:@"Bryant-Bold" size:16];
    
    self.font = customFont;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
