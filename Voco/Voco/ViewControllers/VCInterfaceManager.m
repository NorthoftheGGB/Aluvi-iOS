//
//  VCInterfaceManager.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCInterfaceManager.h"
#import "VCOnboardingViewController.h"
#import "VCTicketViewController.h"
#import "VCLeftMenuViewController.h"
#import "IIViewDeckController.h"
#import "VCApi.h"
#import "VCUserStateManager.h"

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

    } else {
        [self showRiderSigninInterface];
    }
}

- (void) showRiderSigninInterface {
    VCOnboardingViewController * vc = [[VCOnboardingViewController alloc] init];
    vc.view.frame = [[UIApplication sharedApplication] delegate].window.frame;
    
    [[UIApplication sharedApplication] delegate].window.rootViewController = vc;
    [vc.view setNeedsLayout];

    deckController = nil;
    
    [self setMode: kOnBoardingMode];
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
    
    if(deckController == nil){
        [self createDeckViewController];
    }
    
    [_centerNavigationController setViewControllers:@[rideViewController]];
    
    [self setMode: kServiceMode];

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
    [deckController closeLeftView];
    
}

// For Driver

- (void) rideInvoked:(NSNotification *) notification {
    [deckController closeLeftView];
   
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES; // until we have hamburger everywhere
    //return NO;
}

@end
