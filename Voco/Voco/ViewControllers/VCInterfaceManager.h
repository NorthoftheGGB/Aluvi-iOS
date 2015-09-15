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

#define kSkipTutorial @"kSkipTutorial"


@interface VCInterfaceManager : NSObject

+ (VCInterfaceManager * ) instance;
- (void) setCenterViewControllers:(NSArray *) viewControllers;
- (void) showInterface;
- (void) showRiderSigninInterface;
- (void) showRiderInterface;
- (int) mode;

@end
