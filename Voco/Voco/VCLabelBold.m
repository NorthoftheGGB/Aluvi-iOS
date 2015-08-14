//
//  VCLabelBold.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//
//nothing to see here

#import "VCLabelBold.h"

@implementation VCLabelBold




- (void)awakeFromNib{
    
    UIFont *customFont = [UIFont fontWithName:@"Bryant-Medium" size:14 ];
    
    [self setFont:customFont];
    
}



@end
