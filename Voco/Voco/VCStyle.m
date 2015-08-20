//
//  VCStyle.m
//  Voco
//
//  Created by snacks on 8/11/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCStyle.h"

@implementation VCStyle

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

+ (UIColor *) greyColor{
    return [UIColor colorWithRed:.36 green:.40 blue:.40 alpha:1];
}

+ (UIColor *) drkBlueColor{
    return [UIColor colorWithRed:.20 green:.51 blue:.53 alpha:1];
}

+ (UIFont *) boldFont {
    return [UIFont fontWithName:@"Bryant-Medium" size:14 ];
}

+ (UIFont *) regularFont {
    return [UIFont fontWithName:@"Bryant-Regular" size:16 ];
}


@end
