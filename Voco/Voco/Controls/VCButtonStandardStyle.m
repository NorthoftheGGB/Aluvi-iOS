//
//  VCTextFieldBold.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCButtonStandardStyle.h"


@implementation VCButtonStandardStyle



- (void)awakeFromNib{
    

    UIFont *customFont = [UIFont fontWithName:@"Bryant-Bold" size:16];
    
    [self.titleLabel setFont:customFont];
    
}
    



@end
