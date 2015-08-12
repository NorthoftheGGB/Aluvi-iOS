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
    

    UIFont *customFont = [UIFont fontWithName:@"Bryant-Regular" size:[fontSize intValue] ];

    
    
    [self setFont:customFont];
    
}


@end
