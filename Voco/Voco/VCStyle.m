//
//  VCStyle.m
//  Voco
//
//  Created by snacks on 8/11/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCStyle.h"

@implementation VCStyle

+ (UIColor *) drkGreenColor {
    return [UIColor colorWithRed:0.22 green:0.54 blue:0.41 alpha:1];
}

+ (id) drkGreenCGColor {
    return (id) [[self drkGreenColor] CGColor];
}


+ (UIColor *) greenColor {
    return [UIColor colorWithRed:.31 green:.65 blue:.50 alpha:1];
}

+ (id) greenCGColor {
    return (id) [[self greenColor] CGColor];
}


+ (UIColor *) blueColor {
    return [UIColor colorWithRed:.28 green:.61 blue:.64 alpha:1];
}

+ (id) blueCGColor {
    return (id) [[self blueColor] CGColor];
}

+ (NSArray *) gradientColors{
    return @[[self greenCGColor], [self blueCGColor] ];
}

+ (CAGradientLayer *) gradientLayer: (CGRect) frame {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    return gradient;
}

+ (NSArray *) gradient2Colors{
    return @[[self drkGreenCGColor], [self greenCGColor], [self greenCGColor], [self blueCGColor] ];
}

+ (CAGradientLayer *) gradient2Layer: (CGRect) frame {
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    gradient2.frame = frame;
    gradient2.colors = [VCStyle gradient2Colors];
    gradient2.startPoint = CGPointMake(0.0, 0.5);
    gradient2.endPoint = CGPointMake(1.0, 0.5);
    return gradient2;
}




+ (UIColor *) greyColor{
    return [UIColor colorWithRed:.36 green:.40 blue:.40 alpha:1];
}

+ (UIColor *) drkBlueColor{
    return [UIColor colorWithRed:.20 green:.51 blue:.53 alpha:1];
}

+ (UIFont *) boldFont {
    return [UIFont fontWithName:@"Bryant-Medium" size:16 ];
}

+ (UIFont *) regularFont {
    return [UIFont fontWithName:@"Bryant-Regular" size:16 ];
}

+ (UIButton *) barButton {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.backgroundColor = [UIColor whiteColor].CGColor;
    button.layer.cornerRadius = 5.0;
    button.layer.masksToBounds = NO;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.shadowColor = [VCStyle drkBlueColor].CGColor;
    button.layer.shadowOpacity = 1;
    button.layer.shadowRadius = 0;
    button.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    [button setFrame:CGRectMake(0, 0, 150, 28)];
    [button setTitleColor:[VCStyle greyColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Bryant-Regular" size:16.0];
    return button;
}

@end
