//
//  VCButtonFont.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCButton.h"

@implementation VCButton

@synthesize fontSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        fontSize = [NSNumber numberWithInt:30];
    }
    return self;
}

- (void)awakeFromNib{
    
    //old style
    //UIFont *customFont = [UIFont fontWithName:@"KlinicSlab-Light" size:[fontSize intValue] ];
    
    //revision 2.0 style
    UIFont *customFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:[fontSize intValue] ];
    
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
