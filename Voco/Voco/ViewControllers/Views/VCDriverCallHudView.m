//
//  VCDriverCallHudView.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverCallHudView.h"
#import "VCButton.h"

@interface VCDriverCallHudView ()

@property (weak, nonatomic) IBOutlet VCButton *riderCallButton1;
@property (weak, nonatomic) IBOutlet VCButton *riderCallButton2;
@property (weak, nonatomic) IBOutlet VCButton *riderCallButton3;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIconImageView;

@end

@implementation VCDriverCallHudView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) setRiders:(NSArray *)riders {
    _riders = riders;
    NSArray * buttons = @[_riderCallButton1, _riderCallButton2, _riderCallButton3];
    long count = [riders count];
    int i = 0;
    for(; i<count; i++){
        Rider * rider = [riders objectAtIndex:i];
        VCButton * button = ((VCButton *) [buttons objectAtIndex:i]);
        [button setTitle:[rider fullName] forState:UIControlStateNormal];
    }
    for(; i<3; i++){
            ((VCButton *) [buttons objectAtIndex:i]).hidden = YES;
    }
}

@end
