//
//  VCInterfaceModes.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCInterfaceModes.h"
#import "SignInViewController.h"
#import "VCRiderHomeViewController.h"
#import "VCRiderMenuViewController.h"
#import "IIViewDeckController.h"

@implementation VCInterfaceModes

+ (void) showRiderSigninInterface {
    SignInViewController * signInViewController = [[SignInViewController alloc] init];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:signInViewController];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigationController;
}

+ (void) showRiderInterface {
    VCRiderHomeViewController * riderHomeViewController = [[VCRiderHomeViewController alloc] init];
    VCRiderMenuViewController * riderMenuViewController = [[VCRiderMenuViewController alloc] init];
    
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:riderHomeViewController leftViewController:riderMenuViewController rightViewController:nil];
    deckController.leftSize = 320;
    deckController.openSlideAnimationDuration = 0.20f;
    deckController.closeSlideAnimationDuration = 0.20f;
    [[UIApplication sharedApplication] delegate].window.rootViewController = deckController;

}

+ (void) showDriverInterface {
    
}

@end
