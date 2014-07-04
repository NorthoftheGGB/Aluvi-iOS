//
//  SignInViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCSignInViewController.h"
#import "VCTextField.h"
#import "VCUserState.h"
#import "VCRiderHomeViewController.h"
#import "VCSignUpViewController.h"
#import "VCPasswordRecoveryViewController.h"
#import "VCDriverRequestViewController.h"
#import "VCInterfaceModes.h"
#import <MBProgressHUD.h>

#define kPhoneFieldTag 1
#define kPasswordFieldTag 2

@interface VCSignInViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordField;
- (IBAction)didTapSignUp:(id)sender;
- (IBAction)didTapLogin:(id)sender;
- (IBAction)didTapForgotPassword:(id)sender;
- (IBAction)didTapInterestedInDriving:(id)sender;
- (IBAction)didEndOnExit:(id)sender;

@end

@implementation VCSignInViewController

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
    self.title = @"Sign In";
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
}

- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didTapSignUp:(id)sender {
    VCSignUpViewController * signUpViewController = [[VCSignUpViewController alloc] init];
    [self.navigationController pushViewController:signUpViewController animated:YES];
    
}

- (IBAction)didTapLogin:(id)sender {
    [self login];
}

- (void) login {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging In";
    
    [[VCUserState instance] loginWithPhone:_phoneNumberField.text
                                  password:_passwordField.text
                                   success:^{
                                       [hud hide:YES];
                                       [[VCInterfaceModes instance] showRiderInterface];
                                       
                                   } failure:^{
                                       [hud hide:YES];
                                       [UIAlertView showWithTitle:@"Login Failed!" message:@"Invalid" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                   }];
    
    
}

- (IBAction)didTapForgotPassword:(id)sender {
    VCPasswordRecoveryViewController * passwordRecoveryViewController = [[VCPasswordRecoveryViewController alloc] init];
    [self.navigationController pushViewController:passwordRecoveryViewController animated:YES];
}

- (IBAction)didTapInterestedInDriving:(id)sender {
    VCDriverRequestViewController * driverRequestViewController = [[VCDriverRequestViewController alloc] init];
    [self.navigationController pushViewController:driverRequestViewController animated:YES];
}


- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kPhoneFieldTag:
            [_passwordField becomeFirstResponder];
            break;
        case kPasswordFieldTag:
            [self.view endEditing:YES];
            [self login];
            break;
        }
}


@end
