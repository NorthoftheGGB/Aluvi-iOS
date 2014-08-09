//
//  VCLabelBold.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLabelBold.h"

@implementation VCLabelBold

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
    
    //rev 1.0
    //UIFont *customFont = [UIFont fontWithName:@"KlinicSlab-Light" size:[fontSize intValue] ];
    
    //rev 2.0
    UIFont *customFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:[fontSize intValue] ];
    
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
