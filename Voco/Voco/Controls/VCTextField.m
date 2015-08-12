//
//  VCTextField.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTextField.h"

@implementation VCTextField
@synthesize fontSize;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        fontSize = [NSNumber numberWithInt:13];
        self.validateOnFocusLossOnly = TRUE;
    }
    return self;
}


- (void)awakeFromNib{
        
    //old
    //UIFont *customFont = [UIFont fontWithName:@"KlinicSlab-Light" size:[fontSize intValue] ];
    
    //revision 2.0 style
    UIFont *customFont = [UIFont fontWithName:@"Bryant-Regular" size:[fontSize intValue] ];
    
    [self setFont:customFont];

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
