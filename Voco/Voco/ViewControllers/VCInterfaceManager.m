//
//  VCInterfaceManager.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCInterfaceManager.h"
#import "VCLogInViewController.h"
#import "VCTicketViewController.h"
#import "VCDriveViewController.h"
#import "VCLeftMenuViewController.h"
#import "IIViewDeckController.h"
#import "VCApi.h"
#import "VCDriverHomeViewController.h"
#import "VCRequestsViewController.h"
#import "VCUserStateManager.h"
#import "VCDebugViewController.h"

#define kInterfaceModeKey @"INTERFACE_MODE_KEY"

static VCInterfaceManager * instance;
static IIViewDeckController* deckController;
static int mode;

@interface VCInterfaceManager () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UINavigationController * centerNavigationController;

@end

@implementation VCInterfaceManager

+ (VCInterfaceManager * ) instance {
    if(instance == nil){
        instance = [[VCInterfaceManager alloc] init];
        mode =  [(NSNumber*) [[NSUserDefaults standardUserDefaults] objectForKey:kInterfaceModeKey] intValue];
    }
    return instance;
}

- (void) showInterface {
    
    if([VCApi loggedIn]){
        [self showRiderInterface];

        /*if(mode == kDriverMode) {
            [self showDriverInterface];
        } else {
            [self showRiderInterface];
        }
         */
    } else {
        [self showRiderSigninInterface];
    }
}

- (void) showRiderSigninInterface {
    VCLogInViewController * signInViewController = [[VCLogInViewController alloc] init];
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
    
    deckController =  [[IIViewDeckController alloc] init];
    deckController.leftSize = 48;
    deckController.openSlideAnimationDuration = 0.20f;
    deckController.closeSlideAnimationDuration = 0.20f;
    deckController.panningGestureDelegate = self;
    _centerNavigationController = [[UINavigationController alloc] init];
    _centerNavigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-list"]
                                                                                       style:UIBarButtonItemStyleBordered
                                                                                      target:deckController
                                                                                      action:@selector(toggleLeftView)];
    [_centerNavigationController.navigationBar setTranslucent:YES];
    deckController.centerController = _centerNavigationController;
    
    VCLeftMenuViewController * riderMenuViewController = [[VCLeftMenuViewController alloc] init];
    deckController.leftController = riderMenuViewController;
    
    [[UIApplication sharedApplication] delegate].window.rootViewController = deckController;

}

- (void) showRiderInterface {
    VCTicketViewController * rideViewController = [[VCTicketViewController alloc] init];

    if( [VCUserStateManager instance].underwayFareId != nil ) {
        NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fare_id = %@", [VCUserStateManager instance].underwayFareId];
        [fetch setPredicate:predicate];
        NSError * error;
        NSArray * items = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
        if(items != nil && [items count] > 0){
            rideViewController.ticket = [items objectAtIndex:0];
        }
    }
    
    if(deckController == nil){
        [self createDeckViewController];
    }
    
    [_centerNavigationController setViewControllers:@[rideViewController]];
    
    [self setMode: kRiderMode];

}

- (void) showDriverInterface {
    
    if(deckController == nil){
        [self createDeckViewController];
    }
    
    /*
<<<<<<< HEAD:Voco/Voco/ViewControllers/VCInterfaceModes.m
    VCDriveViewController * driveViewController = [[VCDriveViewController alloc] init];
    deckController.centerController = driveViewController;

    
    if([[VCUserState instance].driverState isEqualToString:kDriverStateActive]
       || [[VCUserState instance].driverState isEqualToString:kDriverStateOnDuty] ) {
           VCDriverHomeViewController * driverViewController = [[VCDriverHomeViewController alloc] init];
           deckController.centerController = driverViewController;
           [self setMode: kDriverMode];
					 =======
					 if([[VCUserStateManager instance].driverState isEqualToString:kDriverStateActive]
       || [[VCUserStateManager instance].driverState isEqualToString:kDriverStateOnDuty] ) {
        VCDriverHomeViewController * driverViewController = [[VCDriverHomeViewController alloc] init];
        
        NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Fare"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fare_id    = %@", [VCUserStateManager instance].underwayFareId];
        [fetch setPredicate:predicate];
        NSError * error;
        NSArray * items = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
        if(items != nil && [items count] > 0){
            driverViewController.fare = [items objectAtIndex:0];
        }
        
        deckController.centerController = driverViewController;
        [self setMode: kDriverMode];
>>>>>>> master:Voco/Voco/ViewControllers/VCInterfaceManager.m
    }
     */
    
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

- (void) setCenterViewControllers:(NSArray *) viewControllers{
    [deckController closeLeftViewAnimated:YES];
    [_centerNavigationController setViewControllers:viewControllers];
}


- (id) init {
    self =  [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareOfferInvokedNotification:) name:@"fare_offer_invoked" object:nil];
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
- (void) fareOfferInvokedNotification:(NSNotification *)notification{
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


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES; // until we have hamburger everywhere
    //return NO;
}

@end
