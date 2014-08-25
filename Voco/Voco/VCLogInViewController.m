//
//  VCLogInViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLogInViewController.h"
#import "VCTextField.h"
#import "VCButtonStandardStyle.h"


@interface VCLogInViewController ()
@property (weak, nonatomic) IBOutlet VCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

- (IBAction)didTapSignIn:(id)sender;

- (IBAction)didTapForgotPassword:(id)sender;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSignIn:(id)sender {
}

- (IBAction)didTapForgotPassword:(id)sender {
}
@end
