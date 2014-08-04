//
//  VCRiderMenuViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/11/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCMenuViewController.h"
#import "VCInterfaceManager.h"
#import "VCUserStateManager.h"
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

    [[VCUserStateManager instance] addObserver:self forKeyPath:@"driverState" options:NSKeyValueObservingOptionNew context:XXContext];

    
    UISwipeGestureRecognizer* swipeUpGestureRecognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSoftResetGesture:)];
    swipeUpGestureRecognizer2.direction = UISwipeGestureRecognizerDirectionUp;
    swipeUpGestureRecognizer2.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:swipeUpGestureRecognizer2];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // refresh the view in case it has changed
    switch([[VCInterfaceManager instance] mode]){
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
    [[VCUserStateManager instance] removeObserver:self forKeyPath:@"driverState"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handleSoftResetGesture:(id)sender {
    [UIAlertView showWithTitle:@"Soft Reset" message:@"Are you sure you want to reset ride state for this user?" cancelButtonTitle:@"No!" otherButtonTitles:@[@"Yep, do it"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex == 1){
            [[VCUserStateManager instance] clearRideState];
            [[VCInterfaceManager instance] showInterface];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([[VCInterfaceManager instance] mode] == kDriverMode && [keyPath isEqualToString:@"driverState"]){
        [self showDriverView];
    }
}

- (IBAction)didChangeMode:(id)sender {
    if(_modeSegementedControl.selectedSegmentIndex == 1){
        [self showDriverView];
        [[VCInterfaceManager instance] showDriverInterface];
    } else {
        
        if([[VCUserStateManager instance].driverState isEqualToString: kDriverStateOnDuty]){
            [[VCUserStateManager instance] clockOffWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [UIAlertView showWithTitle:@"Clocked off" message:@"You are now off duty" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                [_onDutySwitch setOn:NO];
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
    [[VCInterfaceManager instance] showRiderInterface];
}

- (void) showDriverView {
    UIView * view;
    if([[VCUserStateManager instance].driverState isEqualToString:kDriverStateActive]
       || [[VCUserStateManager instance].driverState isEqualToString:kDriverStateOnDuty]){
        view = _driverMenu;
        if([[VCUserStateManager instance].driverState isEqualToString:kDriverStateOnDuty]){
            _onDutySwitch.on = YES;
        } else {
            _onDutySwitch.on = NO;
        }
    } else if ([[VCUserStateManager instance].driverState isEqualToString:kDriverStateApproved]){
        view = _requestApproved;
    } else if ([[VCUserStateManager instance].driverState isEqualToString:kDriverStateInterested]){
        view = _requestPending;
    } else if ([[VCUserStateManager instance].driverState isEqualToString:kDriverStateRegistered]){
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
    [[VCUserStateManager instance] logout];
    [[VCInterfaceManager instance] showRiderSigninInterface];
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
    if([[VCUserStateManager instance].driverState isEqualToString:@"approved" ]){
        VCDriverRegistrationViewController * vc = [[VCDriverRegistrationViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if([[VCUserStateManager instance].driverState isEqualToString:@"registered" ]){
        VCDriverVideoTutorialController * vc = [[VCDriverVideoTutorialController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)didChangeOnDutySwitch:(id)sender {
    UISwitch * onDutySwitch = (UISwitch *) sender;
    if(onDutySwitch.isOn){
        [[VCUserStateManager instance] clockOnWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [UIAlertView showWithTitle:@"Ready to Drive" message:@"You are now on duty" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            onDutySwitch.on = NO;
        }];
    } else {
        [[VCUserStateManager instance] clockOffWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [UIAlertView showWithTitle:@"Clocked off" message:@"You are now off duty" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
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
    [[VCInterfaceManager instance] showDebugInterface];
}

@end
