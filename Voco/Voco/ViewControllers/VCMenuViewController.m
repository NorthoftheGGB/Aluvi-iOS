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
#import "VCRequestsViewController.h"
#import "VCDriverApi.h"
#import "VCFaresViewController.h"
#import "VCCommuterPassViewController.h"
#import "VCRiderPaymentsViewController.h"
#import "VCDriverEarningsViewController.h"
#import "VCDriverProfileViewController.h"
#import "VCRiderProfileViewController.h"
#import "VCMenuItemModeTableViewCell.h"
#import "VCMenuItemNotConfiguredTableViewCell.h"

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
@property (nonatomic) BOOL appeared;

@property (nonatomic) NSInteger driverReset;

// Rider Menu
- (IBAction)didTapUserMode:(id)sender;
- (IBAction)didTapProfile:(id)sender;
- (IBAction)didTapPaymentInfo:(id)sender;
- (IBAction)didTapScheduledRides:(id)sender;
- (IBAction)didTapCommuterPass:(id)sender;
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
    
    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpFrom:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    swipeUpGestureRecognizer.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:swipeUpGestureRecognizer];

    [[VCUserState instance] addObserver:self forKeyPath:@"driverState" options:NSKeyValueObservingOptionNew context:XXContext];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // refresh the view in case it has changed
    switch([[VCInterfaceModes instance] mode]){
        case kDriverMode:
            [_modeSegementedControl setSelectedSegmentIndex:1];
            [self showDriverView];
            break;
        default:
            [_modeSegementedControl setSelectedSegmentIndex:0];
            [self showRiderMenu];
            break;
    }
    _appeared = YES;

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
    if(_appeared){
        _appeared = NO;
    }
}

- (void)dealloc {
    [[VCUserState instance] removeObserver:self forKeyPath:@"driverState"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([[VCInterfaceModes instance] mode] == kDriverMode && [keyPath isEqualToString:@"driverState"]){
        [self showDriverView];
    }
}

- (IBAction)didChangeMode:(id)sender {
    if(_modeSegementedControl.selectedSegmentIndex == 1){
        [self showDriverView];
        [[VCInterfaceModes instance] showDriverInterface];
    } else {
        
        if([[VCUserState instance].driverState isEqualToString: kDriverStateOnDuty]){
            [VCDriverApi clockOffWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [_modeSegementedControl setSelectedSegmentIndex:0];
                [self displayRiderMode];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                
            }];
        } else {
            [self displayRiderMode];
        }
    }
}

- (void) displayRiderMode {
    [self showRiderMenu];
    [[VCInterfaceModes instance] showRiderInterface];
}

- (void) showDriverView {
    UIView * view;
    if([[VCUserState instance].driverState isEqualToString:kDriverStateActive]
       || [[VCUserState instance].driverState isEqualToString:kDriverStateOnDuty]){
        view = _driverMenu;
        if([[VCUserState instance].driverState isEqualToString:kDriverStateOnDuty]){
            _onDutySwitch.on = YES;
        }
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
        
        //view.frame = _menuContainer.frame;
        
        CGRect frame = _menuContainer.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        _driverMenu.frame = frame;
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
    
    CGRect frame = _menuContainer.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    _riderMenu.frame = frame;
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
    [[VCInterfaceModes instance] showRiderSigninInterface];
}

//rider actions

- (IBAction)didTapUserMode:(id)sender {
}

- (IBAction)didTapProfile:(id)sender {
    VCRiderProfileViewController * vc = [[VCRiderProfileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapPaymentInfo:(id)sender {
    VCRiderPaymentsViewController * vc = [[VCRiderPaymentsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapScheduledRides:(id)sender {
    VCRequestsViewController * vc = [[VCRequestsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapCommuterPass:(id)sender {
    VCCommuterPassViewController * vc = [[VCCommuterPassViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
    VCDriverProfileViewController * vc = [[VCDriverProfileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapDriverPaymentInfo:(id)sender {
    VCDriverEarningsViewController * vc = [[VCDriverEarningsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapDriverScheduledFares:(id)sender {
    VCFaresViewController * vc = [[VCFaresViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
    UISwitch * onDutySwitch = (UISwitch *) sender;
    if(onDutySwitch.isOn){
        [[VCUserState instance] clockOnWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [UIAlertView showWithTitle:@"Ready to Drive" message:@"You are on duty" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            onDutySwitch.on = NO;
        }];
    } else {
        [[VCUserState instance] clockOffWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [UIAlertView showWithTitle:@"Clocked off" message:@"You are off duty" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            onDutySwitch.on = YES;
        }];
    }
    
    
}

- (IBAction)driverResetDown:(id)sender {
    _driverReset++;
}

- (IBAction)driverResetUp:(id)sender {
    _driverReset--;
}

- (void)handleSwipeUpFrom:(UIGestureRecognizer*)recognizer {
    [[VCInterfaceModes instance] showDebugInterface];
}

@end
