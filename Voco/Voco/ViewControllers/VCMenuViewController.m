//
//  VCRiderMenuViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/11/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCMenuViewController.h"
#import "VCInterfaceModes.h"
#import "VCUserState.h"
#import "VCDriverRequestViewController.h"
#import "VCDriverRegistrationViewController.h"
#import "VCDriverVideoTutorialController.h"
#import "VCRiderRidesViewController.h"

static void * XXContext = &XXContext;

@interface VCMenuViewController ()

@property (weak, nonatomic) IBOutlet UIView *menuContainer;
@property (strong, nonatomic) IBOutlet UIView *riderMenu;
@property (strong, nonatomic) IBOutlet UIView *driverMenu;
@property (strong, nonatomic) IBOutlet UIView *notYetRegistered;
@property (strong, nonatomic) IBOutlet UIView *requestPending;
@property (strong, nonatomic) IBOutlet UIView *requestDenied;
@property (strong, nonatomic) IBOutlet UIView *requestApproved;
@property (strong, nonatomic) IBOutlet UIView *registeredNotActivated;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegementedControl;
@property (weak, nonatomic) IBOutlet UISwitch *onDutySwitch;

// Rider Menu
- (IBAction)didTapUserMode:(id)sender;
- (IBAction)didTapProfile:(id)sender;
- (IBAction)didTapPaymentInfo:(id)sender;
- (IBAction)didTapScheduledRides:(id)sender;
- (IBAction)didTapCummuterPass:(id)sender;
- (IBAction)didTapAboutUs:(id)sender;
- (IBAction)didTapTermsAndConditions:(id)sender;
- (IBAction)didTapSupport:(id)sender;
- (IBAction)didTapTutorial:(id)sender;

// Driver Menu
- (IBAction)didTapDriverProfile:(id)sender;
- (IBAction)didTapDriverPaymentInfo:(id)sender;
- (IBAction)didTapDriverScheduledFares:(id)sender;
- (IBAction)didTapDriverMyCar:(id)sender;
- (IBAction)didTapDriverAboutUs:(id)sender;
- (IBAction)didTapDriverTermsAndConditions:(id)sender;
- (IBAction)didTapDriverSupport:(id)sender;
- (IBAction)didTapDriverTutorial:(id)sender;

// Driver Onboarding
- (IBAction)didTapInterestedInDriving:(id)sender;
- (IBAction)didTapRegister:(id)sender;

// Modes
- (IBAction)didChangeOnDutySwitch:(id)sender;
- (IBAction)didChangeMode:(id)sender;
- (IBAction)didTapLogout:(id)sender;

@end

@implementation VCMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"settings";
    
    switch([VCInterfaceModes mode]){
        case kDriverMode:
            [_modeSegementedControl setSelectedSegmentIndex:1];
            [self showDriverView];
            break;
        default:
            [_modeSegementedControl setSelectedSegmentIndex:0];
            [self showRiderMenu];
            break;
    }

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(didTapLogout:)];
    self.navigationItem.rightBarButtonItem = logoutButton;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // refresh the view in case it has changed
    if([VCInterfaceModes mode] == kDriverMode){
        [self showDriverView];
    }
    [[VCUserState instance] addObserver:self forKeyPath:@"driverState" options:NSKeyValueObservingOptionNew context:XXContext];

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
    [[VCUserState instance] removeObserver:self forKeyPath:@"driverState"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([VCInterfaceModes mode] == kDriverMode && [keyPath isEqualToString:@"driverState"]){
        [self showDriverView];
    }
}

- (IBAction)didChangeMode:(id)sender {
    if(_modeSegementedControl.selectedSegmentIndex == 1){
        [self showDriverView];
        [VCInterfaceModes showDriverInterface];
    } else {
        [self showRiderMenu];
        [VCInterfaceModes showRiderInterface];

    }
}

- (void) showDriverView {
    UIView * view;
    if([[VCUserState instance].driverState isEqualToString:kDriverStateActive]
       || [[VCUserState instance].driverState isEqualToString:kDriverStateOnDuty]){
        view = _driverMenu;
    } else if ([[VCUserState instance].driverState isEqualToString:kDriverStateApproved]){
        view = _requestApproved;
    } else if ([[VCUserState instance].driverState isEqualToString:kDriverStateInterested]){
        view = _requestPending;
    } else if ([[VCUserState instance].driverState isEqualToString:kDriverStateRegistered]){
        view = _registeredNotActivated;
    } else {
        view = _notYetRegistered;
    }
    if(! [_menuContainer.subviews containsObject:view]){
        
        view.frame = _menuContainer.frame;
        [UIView transitionWithView:_menuContainer
                          duration:.45f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [[_menuContainer subviews]
                             makeObjectsPerformSelector:@selector(removeFromSuperview)];
                            [_menuContainer addSubview:view];
                        } completion:nil];
    }
}

- (void) showRiderMenu {
    
    _riderMenu.frame = _menuContainer.frame;
    [UIView transitionWithView:_menuContainer
                      duration:.45f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [[_menuContainer subviews]
                         makeObjectsPerformSelector:@selector(removeFromSuperview)];
                        [_menuContainer addSubview:_riderMenu];
                    } completion:nil];
}


- (IBAction)didTapLogout:(id)sender {
    [self viewWillDisappear:YES];
    [[VCUserState instance] logout];
    [VCInterfaceModes showRiderSigninInterface];
}

//rider actions

- (IBAction)didTapUserMode:(id)sender {
}

- (IBAction)didTapProfile:(id)sender {
}

- (IBAction)didTapPaymentInfo:(id)sender {
}

- (IBAction)didTapScheduledRides:(id)sender {
    VCRiderRidesViewController * vc = [[VCRiderRidesViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapCummuterPass:(id)sender {
}

- (IBAction)didTapAboutUs:(id)sender {
}

- (IBAction)didTapTermsAndConditions:(id)sender {
}

- (IBAction)didTapSupport:(id)sender {
}

- (IBAction)didTapTutorial:(id)sender {
}



//driver actions

- (IBAction)didTapDriverProfile:(id)sender {
}

- (IBAction)didTapDriverPaymentInfo:(id)sender {
}

- (IBAction)didTapDriverScheduledFares:(id)sender {
}

- (IBAction)didTapDriverMyCar:(id)sender {
}

- (IBAction)didTapDriverAboutUs:(id)sender {
}

- (IBAction)didTapDriverTermsAndConditions:(id)sender {
}

- (IBAction)didTapDriverSupport:(id)sender {
}

- (IBAction)didTapDriverTutorial:(id)sender {
}

- (IBAction)didTapInterestedInDriving:(id)sender {
    [self viewWillDisappear:YES];
    VCDriverRequestViewController * vc = [[VCDriverRequestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapRegister:(id)sender {
    [self viewWillDisappear:YES];
    if([[VCUserState instance].driverState isEqualToString:@"approved" ]){
        VCDriverRegistrationViewController * vc = [[VCDriverRegistrationViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if([[VCUserState instance].driverState isEqualToString:@"registered" ]){
        VCDriverVideoTutorialController * vc = [[VCDriverVideoTutorialController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)didChangeOnDutySwitch:(id)sender {
}

@end