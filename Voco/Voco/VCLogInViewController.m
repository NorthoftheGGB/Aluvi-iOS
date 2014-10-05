//
//  VCLogInViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLogInViewController.h"
#import <MBProgressHUD.h>
#import "VCUserStateManager.h"
#import "VCInterfaceManager.h"
#import "VCRiderApi.h"
#import "VCTextField.h"
#import "VCButtonStandardStyle.h"
#import "VCPasswordRecoveryViewController.h"
#import "VCTermsOfServiceViewController.h"
#import "VCNotifications.h"

#define kPhoneFieldTag 1
#define kPasswordFieldTag 2

@interface VCLogInViewController ()
@property (weak, nonatomic) IBOutlet VCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

- (IBAction)didTapSignIn:(id)sender;

- (IBAction)didTapForgotPassword:(id)sender;
- (IBAction)didTapTermsAndConditions:(id)sender;

@end

@implementation VCLogInViewController

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
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    [self.navigationController setNavigationBarHidden:YES animated:NO];\
    
#ifndef RELEASE
    UISwipeGestureRecognizer * shortCut = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(debug:)];
    [shortCut setNumberOfTouchesRequired:2];
    [shortCut setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:shortCut];
#endif

}

- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}

- (void) debug:(id) sender {
    

    NSArray * userEmails = [NSArray array];
    NSArray * passwords = [NSArray array];
    NSArray * userLabels = [NSArray array];

#ifdef TESTING
    userEmails = @[ @"v1@vocotransportation.com", @"v3@vocotransportation.com"];
    passwords = @[ @"abc123456", @"abc123456"];
    userLabels = @[ @"rider", @"driver"];
#elif ALPHA

#else
    userEmails = @[ @"v1@vocotransportation.com", @"v3@vocotransportation.com"];
    passwords = @[ @"9999999999", @"5555555555" ];
    userLabels = @[  @"rider", @"driver"];
#endif

    
    [UIAlertView showWithTitle:@"Debug" message:@"Log In?" cancelButtonTitle:@"No" otherButtonTitles:userLabels tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if(buttonIndex <= [userEmails count]){
            _emailTextField.text = [userEmails objectAtIndex:buttonIndex-1];
            _passwordTextField.text = [passwords objectAtIndex:buttonIndex-1];
            [self login];
        } else {
            
        }
        
    }];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSignIn:(id)sender {
    [self login];
}

- (void) login {
    
    
    if(![_emailTextField validate]){
        return;
    }
    
    if(![_passwordTextField validate]){
        return;
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging In";
    
    [[VCUserStateManager instance] loginWithEmail:_emailTextField.text
                                         password:_passwordTextField.text
                                          success:^{
                                              
                                              [VCRiderApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  [hud hide:YES];
                                                  [[VCInterfaceManager instance] showRiderInterface];
                                                  [VCNotifications scheduleUpdated];
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  [WRUtilities criticalError:error];
                                                  [hud hide:YES];
                                                  
                                              }];
                                              
                                          } failure:^{
                                              [hud hide:YES];
                                              [UIAlertView showWithTitle:@"Login Failed!" message:@"Invalid Email or Password.  " cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                          }];
    
    
}


- (IBAction)didTapForgotPassword:(id)sender {
    VCPasswordRecoveryViewController * passwordRecoveryViewController = [[VCPasswordRecoveryViewController alloc] init];
    [self.navigationController pushViewController:passwordRecoveryViewController animated:YES];

}

- (IBAction)didTapTermsAndConditions:(id)sender {
    
    VCTermsOfServiceViewController * vc = [[VCTermsOfServiceViewController alloc] init];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    if([textField.text length] > 0){
        textField.backgroundColor = [UIColor whiteColor];
    }
    
    switch(textField.tag){
        case kPhoneFieldTag:
            if ([_emailTextField validate]){
                [_passwordTextField becomeFirstResponder];
            }
            break;
        case kPasswordFieldTag:
            if([_passwordTextField validate]) {
                [self.view endEditing:YES];
                [self login];
            }
            break;
    }
}
@end
