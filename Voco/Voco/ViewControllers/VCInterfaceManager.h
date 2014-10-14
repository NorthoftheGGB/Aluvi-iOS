//
//  VCInterfaceModes.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOnBoardingMode 2
#define kServiceMode 3

@interface VCInterfaceManager : NSObject

+ (VCInterfaceManager * ) instance;
- (void) setCenterViewControllers:(NSArray *) viewControllers;
- (void) showInterface;
- (void) showRiderSigninInterface;
- (void) showRiderInterface;
- (void) showDebugInterface;
- (int) mode;

@end
