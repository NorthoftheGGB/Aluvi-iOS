//
//  VCLabelBold.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//
//nothing to see here

#import "VCLabelBold.h"
#import "VCStyle.h"

@implementation VCLabelBold




- (void)awakeFromNib{
    
    [self setFont:[VCStyle boldFont]];
    
}



@end
