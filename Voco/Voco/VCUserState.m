//
//  VCUserState.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCUserState.h"


static VCUserState *sharedSingleton;

@implementation VCUserState

+ (VCUserState *) instance {
    if(sharedSingleton == nil){
        sharedSingleton = [[VCUserState alloc] init];
        sharedSingleton.interfaceState = VC_INTERFACE_STATE_IDLE;
    }
    return sharedSingleton;
}

+ (BOOL) driverIsAvailable {
    return true; // assumption for now
}


@end
