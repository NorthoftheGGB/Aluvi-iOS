//
//  VCStyle.h
//  Voco
//
//  Created by snacks on 8/11/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@interface VCStyle : NSObject

+ (UIColor *) greenColor;
+ (id) greenCGColor;
+ (UIColor *) blueColor;
+ (id) blueCGColor;

+ (NSArray *) gradientColors;

@end
