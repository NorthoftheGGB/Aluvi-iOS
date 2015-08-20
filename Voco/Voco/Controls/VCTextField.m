//
//  VCTextField.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTextField.h"

@implementation VCTextField




- (void)awakeFromNib{
        
    //old
    //UIFont *customFont = [UIFont fontWithName:@"KlinicSlab-Light" size:[fontSize intValue] ];
    
    //revision 2.0 style
    UIFont *customFont = [UIFont fontWithName:@"Bryant-Regular" size:14];
    
    [self setFont:customFont];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
    


}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
