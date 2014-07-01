//
//  VCInterfaceModes.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDriverMode 0
#define kRiderMode 1
#define kNoMode 2


@interface VCInterfaceModes : NSObject

+ (void) showInterface;
+ (void) showRiderSigninInterface;
+ (void) showRiderInterface;
+ (void) showDriverInterface;
+ (void) showDebugInterface;

+ (int) mode;

@end
