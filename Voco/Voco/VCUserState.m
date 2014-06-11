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
 
        
    }
    return sharedSingleton;
}

+ (BOOL) driverIsAvailable {
    return true; // assumption for now
}

- (id) init {
    self = [super init];
    if(self != nil){
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        _userId = [userDefaults objectForKey:@"userId"];
        _rideId = [userDefaults objectForKey:@"rideId"];
        _riderState = [userDefaults objectForKey:@"riderState"];
        _driverState = [userDefaults objectForKey:@"driverState"];
    }
    return self;
}

- (void) saveState {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_userId forKey:@"userId"];
    [userDefaults setObject:_rideId forKey:@"rideId"];
    [userDefaults setObject:_riderState forKey:@"riderState"];
    [userDefaults setObject:_driverState forKey:@"driverState"];
    [userDefaults synchronize];
}


@end
