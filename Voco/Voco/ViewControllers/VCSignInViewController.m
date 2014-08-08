//
//  SignInViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCSignInViewController.h"
#import "VCTextField.h"
#import "VCUserStateManager.h"
#import "VCRiderHomeViewController.h"
#import "VCSignUpViewController.h"
#import "VCPasswordRecoveryViewController.h"
#import "VCDriverRequestViewController.h"
#import "VCInterfaceManager.h"
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
    
    
    if(![_phoneNumberField validate]){
        return;
    }
    
    if(![_passwordField validate]){
        return;
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging In";
    
    [[VCUserStateManager instance] loginWithPhone:_phoneNumberField.text
                                  password:_passwordField.text
                                   success:^{
                                       [hud hide:YES];
                                       [[VCInterfaceManager instance] showRiderInterface];
                                       
                                   } failure:^{
                                       [hud hide:YES];
                                       [UIAlertView showWithTitle:@"Login Failed!" message:@"Invalid Phone Number or Password" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
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

- (IBAction)editDidBegin:(id)sender {
    UITextField * textField = (UITextField *) sender;
    textField.backgroundColor = [UIColor whiteColor];
}

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    if([textField.text length] > 0){
        textField.backgroundColor = [UIColor whiteColor];
    }
    
    switch(textField.tag){
        case kPhoneFieldTag:
            if ([_phoneNumberField validate]){
                [_passwordField becomeFirstResponder];
            }
            break;
        case kPasswordFieldTag:
            if([_passwordField validate]) {
                [self.view endEditing:YES];
                [self login];
            }
            break;
        }
}


@end
