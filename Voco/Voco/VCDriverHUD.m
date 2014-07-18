//
//  VCDriverHUD.m
//  Voco
//
//  Created by Matthew Shultz on 7/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverHUD.h"

@interface VCDriverHUD ()

@property (nonatomic) NSInteger selectedIndex;

@end

@implementation VCDriverHUD

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectedIndex = -1;
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

- (void) awakeFromNib {
    _riderButton1.tag = 0 + 1000;
    _riderButton2.tag = 1 + 1000;
    _riderButton3.tag = 2 + 1000;
}

- (void) setRiderNames:(NSArray *)names {
    _riderButton1.hidden = YES;
    _riderButton2.hidden = YES;
    _riderButton3.hidden = YES;
    for(int i=0; i < [names count]; i++){
    UIButton * button = (UIButton *) [self viewWithTag:i + 1000];
        [button setTitle:[names objectAtIndex:i] forState:UIControlStateNormal];
        button.hidden = NO;
    }
}

- (IBAction)didTapRiderButton:(id)sender {
    UIButton * button = (UIButton*)sender;
    if (button.selected){
        return;
    }
    _riderButton1.selected = NO;
    _riderButton2.selected = NO;
    _riderButton3.selected = NO;
    button.selected = YES;
    
    _selectedIndex = button.tag - 1000;
}

- (IBAction)didTapCallButton:(id)sender {
    [_delegate didRequestCallForIndex:_selectedIndex];
}


@end
