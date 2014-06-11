//
//  VCInterfaceModes.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCInterfaceModes.h"
#import "SignInViewController.h"

@implementation VCInterfaceModes

+ (void) showRiderSigninInterface {
    SignInViewController * signInViewController = [[SignInViewController alloc] init];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:signInViewController];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigationController;
}

+ (void) showRiderInterface {
    
}

+ (void) showDriverInterface {
    
}

@end
