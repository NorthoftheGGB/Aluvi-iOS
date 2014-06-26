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
#import "VCMenuViewController.h"
#import "IIViewDeckController.h"
#import "VCApi.h"
#import "DriverViewController.h"
#import "VCRiderRidesViewController.h"
#import "VCUserState.h"

#define kInterfaceModeKey @"INTERFACE_MODE_KEY"


static IIViewDeckController* deckController;
static int mode;

@implementation VCInterfaceModes

+ (void) showInterface {
    
    if([VCApi loggedIn]){
        [VCInterfaceModes showRiderInterface];
    } else {
        [VCInterfaceModes showRiderSigninInterface];
        
    }
}

+ (void) showRiderSigninInterface {
    SignInViewController * signInViewController = [[SignInViewController alloc] init];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:signInViewController];
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[UIImage new]];
    [navigationController.navigationBar setTranslucent:YES];
    navigationController.navigationBar.tintColor = [UIColor redColor];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigationController;
    deckController = nil;
    [self setMode:kNoMode];
}

+ (void) createDeckViewController {
    
    deckController =  [[IIViewDeckController alloc] init]; //initWithCenterViewController:riderHomeViewController leftViewController:riderMenuViewController rightViewController:nil];
    deckController.leftSize = 0;
    deckController.openSlideAnimationDuration = 0.20f;
    deckController.closeSlideAnimationDuration = 0.20f;
    deckController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-list"]
                                                                                       style:UIBarButtonItemStyleBordered
                                                                                      target:deckController
                                                                                      action:@selector(toggleLeftView)];
    VCMenuViewController * riderMenuViewController = [[VCMenuViewController alloc] init];
    deckController.leftController = riderMenuViewController;
    
    [deckController.navigationController.navigationBar setTranslucent:YES];

    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:deckController];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigationController;


}

+ (void) showRiderInterface {
    VCRiderHomeViewController * riderHomeViewController = [[VCRiderHomeViewController alloc] init];
    //VCRiderRidesViewController * riderHomeViewController = [[VCRiderRidesViewController alloc] init];
    
    if(deckController == nil){
        [self createDeckViewController];
    }
    
    deckController.centerController = riderHomeViewController;
    
    [self setMode: kRiderMode];

}

+ (void) showDriverInterface {
    
    if(deckController == nil){
        [self createDeckViewController];
    }
    
    if([[VCUserState instance].driverState isEqualToString:kDriverStateActive]
       || [[VCUserState instance].driverState isEqualToString:kDriverStateOnDuty] ) {
           DriverViewController * driverViewController = [[DriverViewController alloc] init];
           deckController.centerController = driverViewController;
           [self setMode: kDriverMode];
    }
}

+ (void) setMode: (int) newMode {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newMode] forKey:kInterfaceModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    mode = newMode;
}

+ (int) mode {
    return mode;
}

@end
