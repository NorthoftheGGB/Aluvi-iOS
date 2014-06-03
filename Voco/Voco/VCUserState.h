//
//  VCUserState.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

// placeholder class for user state tracking, enabling KVO

@interface VCUserState : NSObject


@property(nonatomic, strong) NSNumber * userId;
@property(nonatomic, strong) NSString * riderState;
@property(nonatomic, strong) NSString * driverState;

+ (VCUserState *) instance;
+ (BOOL) driverIsAvailable;


@end
