//
//  VCTextFieldBold.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCButtonFontBold.h"


@implementation VCButtonFontBold

@synthesize fontSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        fontSize = [NSNumber numberWithInt:13];
    }
    return self;
}

- (void)awakeFromNib{
    
    //old style
    //UIFont *customFont = [UIFont fontWithName:@"KlinicSlab-Medium" size:[fontSize intValue] ];
    
    //revision 2.0 style
    UIFont *customFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:[fontSize intValue] ];
    
    [self.titleLabel setFont:customFont];
    
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
