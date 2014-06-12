//
//  SignInViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "SignInViewController.h"
#import "VCTextField.h"
#import "VCUserState.h"
#import "VCRiderHomeViewController.h"
#import "SignUpViewController.h"
#import "PasswordRecoveryViewController.h"
#import "DriverRequestViewController.h"
#import "VCInterfaceModes.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordField;
- (IBAction)didTapSignUp:(id)sender;
- (IBAction)didTapLogin:(id)sender;
- (IBAction)didTapForgotPassword:(id)sender;
- (IBAction)didTapInterestedInDriving:(id)sender;
- (IBAction)didTapReturnKey:(id)sender;

@end

@implementation SignInViewController

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
    SignUpViewController * signUpViewController = [[SignUpViewController alloc] init];
    [self.navigationController pushViewController:signUpViewController animated:YES];
    
}

- (IBAction)didTapLogin:(id)sender {
    [self login];
}

- (void) login {
    
    [[VCUserState instance] loginWithPhone:_phoneNumberField.text
                                  password:_passwordField.text
                                   success:^{
                                       [VCInterfaceModes showRiderInterface];
                                   } failure:^{
                                       [UIAlertView showWithTitle:@"Login Failed!" message:@"Invalid" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                   }];
    
    
}

- (IBAction)didTapForgotPassword:(id)sender {
    PasswordRecoveryViewController * passwordRecoveryViewController = [[PasswordRecoveryViewController alloc] init];
    [self.navigationController pushViewController:passwordRecoveryViewController animated:YES];
}

- (IBAction)didTapInterestedInDriving:(id)sender {
    DriverRequestViewController * driverRequestViewController = [[DriverRequestViewController alloc] init];
    [self.navigationController pushViewController:driverRequestViewController animated:YES];
}

- (IBAction)didTapReturnKey:(id)sender {
    [self.view endEditing:YES];
    [self login];
    
}
@end
