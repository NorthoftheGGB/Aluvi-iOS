//
//  VCCommuterHud.m
//  Voco
//
//  Created by Matthew Shultz on 7/2/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuterHud.h"

@implementation VCCommuterHud

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)didTapOk:(id)sender {
    [self removeFromSuperview];
}
@end
