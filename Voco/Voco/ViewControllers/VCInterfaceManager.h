//
//  VCInterfaceModes.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDriverMode 2
#define kRiderMode 3
#define kNoMode 4


@interface VCInterfaceManager : NSObject

+ (VCInterfaceManager * ) instance;
- (void) setCenterViewControllers:(NSArray *) viewControllers;
- (void) showInterface;
- (void) showRiderSigninInterface;
- (void) showRiderInterface;
- (void) showDriverInterface;
- (void) showDebugInterface;
- (int) mode;

@end
