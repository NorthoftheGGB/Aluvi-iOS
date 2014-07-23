//
//  VCInterfaceModes.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCInterfaceModes.h"
#import "VCSignInViewController.h"
#import "VCRiderHomeViewController.h"
#import "VCMenuViewController.h"
#import "IIViewDeckController.h"
#import "VCApi.h"
#import "VCDriverHomeViewController.h"
#import "VCRequestsViewController.h"
#import "VCUserState.h"
#import "VCDebugViewController.h"

#define kInterfaceModeKey @"INTERFACE_MODE_KEY"

static VCInterfaceModes * instance;
static IIViewDeckController* deckController;
static int mode;

@implementation VCInterfaceModes

+ (VCInterfaceModes * ) instance {
    if(instance == nil){
        instance = [[VCInterfaceModes alloc] init];
        mode =  [(NSNumber*) [[NSUserDefaults standardUserDefaults] objectForKey:kInterfaceModeKey] intValue];
    }
    return instance;
}

- (void) showInterface {
    
    if([VCApi loggedIn]){
        if(mode == kDriverMode) {
            [self showDriverInterface];
        } else {
            [self showRiderInterface];
        }
    } else {
        [self showRiderSigninInterface];
        
    }
}

- (void) showRiderSigninInterface {
    VCSignInViewController * signInViewController = [[VCSignInViewController alloc] init];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:signInViewController];
    /* [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[UIImage new]];*/
    [navigationController.navigationBar setTranslucent:YES];
    navigationController.navigationBar.tintColor = [UIColor redColor];
    [[UIApplication sharedApplication] delegate].window.rootViewController = navigationController;
    deckController = nil;
    [self setMode:kNoMode];
}

- (void) createDeckViewController {
    
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

- (void) showRiderInterface {
    
    VCRiderHomeViewController * riderHomeViewController = [[VCRiderHomeViewController alloc] init];

    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ride"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ride_id = %@", [VCUserState instance].underwayRideId];
    [fetch setPredicate:predicate];
    NSError * error;
    NSArray * items = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
    if(items != nil && [items count] > 0){
        riderHomeViewController.request = [items objectAtIndex:0];
    }
    
    if(deckController == nil){
        [self createDeckViewController];
    }
    
    deckController.centerController = riderHomeViewController;
    
    [self setMode: kRiderMode];

}

- (void) showDriverInterface {
    
    if(deckController == nil){
        [self createDeckViewController];
    }
    
    if([[VCUserState instance].driverState isEqualToString:kDriverStateActive]
       || [[VCUserState instance].driverState isEqualToString:kDriverStateOnDuty] ) {
        VCDriverHomeViewController * driverViewController = [[VCDriverHomeViewController alloc] init];
        
        NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Fare"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ride_id = %@", [VCUserState instance].underwayRideId];
        [fetch setPredicate:predicate];
        NSError * error;
        NSArray * items = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
        if(items != nil && [items count] > 0){
            driverViewController.fare = [items objectAtIndex:0];
        }
        
        deckController.centerController = driverViewController;
        [self setMode: kDriverMode];
    }
    
}

- (void) showDebugInterface{
    VCDebugViewController * vc = [[VCDebugViewController alloc] init];
    [[UIApplication sharedApplication] delegate].window.rootViewController = vc;
    deckController = nil;
}

- (void) setMode: (int) newMode {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newMode] forKey:kInterfaceModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    mode = newMode;
}

- (int) mode {
    return mode;
}


- (id) init {
    self =  [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideOfferInvokedNotification:) name:@"ride_offer_invoked" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commuterRideInvokedNotification:) name:@"commuter_ride_invoked" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideInvoked:) name:@"driver_ride_invoked" object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// For Rider
- (void) commuterRideInvokedNotification:(NSNotification *)notification{
    if(mode == kRiderMode){
        [deckController closeLeftView];
    } else {
        [UIAlertView showWithTitle:@"Woops!"
                           message:@"You must be in rider mode to view your commuter ride"
                 cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
}

// For Driver
- (void) rideOfferInvokedNotification:(NSNotification *)notification{
    if(mode == kDriverMode){
        [deckController closeLeftView];
    } else {
        [UIAlertView showWithTitle:@"Woops!"
                           message:@"You must be in driver mode to view ride offers"
                 cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
    
}
- (void) rideInvoked:(NSNotification *) notification {
    if(mode == kDriverMode){
        [deckController closeLeftView];
    } else {
        [UIAlertView showWithTitle:@"Woops!"
                           message:@"You must be in driver mode to view rides"
                 cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
}


@end
