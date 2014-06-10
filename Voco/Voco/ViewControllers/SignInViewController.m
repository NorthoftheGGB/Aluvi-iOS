//
//  SignInViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "SignInViewController.h"
#import "VCTextField.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordField;
- (IBAction)didTapSignUp:(id)sender;
- (IBAction)didTapLogin:(id)sender;
- (IBAction)didTapForgotPassword:(id)sender;
- (IBAction)didTapInterestedInDriving:(id)sender;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSignIn:(id)sender {
}
- (IBAction)didTapSignUp:(id)sender {
}

- (IBAction)didTapLogin:(id)sender {
}

- (IBAction)didTapForgotPassword:(id)sender {
}

- (IBAction)didTapInterestedInDriving:(id)sender {
}
@end
