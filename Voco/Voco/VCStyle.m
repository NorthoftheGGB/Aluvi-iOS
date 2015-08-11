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



@end
