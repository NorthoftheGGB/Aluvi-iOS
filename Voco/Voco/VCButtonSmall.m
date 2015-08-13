//
//  VCButtonSmall.m
//  Voco
//
//  Created by snacks on 8/13/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCButtonSmall.h"

@implementation VCButtonSmall


- (void)awakeFromNib{
    

    UIFont *customFont = [UIFont fontWithName:@"Bryant-Regular" size:14];
    
    [self.titleLabel setFont:customFont];
    
}



@end
