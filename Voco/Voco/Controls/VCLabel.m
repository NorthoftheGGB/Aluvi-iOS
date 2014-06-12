//
//  VCLabel.m
//  Voco
//
//  Created by Matthew Shultz on 6/12/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLabel.h"

@implementation VCLabel

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
    
    
    UIFont *customFont = [UIFont fontWithName:@"KlinicSlab-Light" size:[fontSize intValue] ];
    
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
