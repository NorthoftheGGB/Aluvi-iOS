//
//  VCDriverCreateAccountViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverCreateAccountViewController.h"
#import "VCTextField.h"

@interface VCDriverCreateAccountViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *nameField;
@property (weak, nonatomic) IBOutlet VCTextField *phoneField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordField;
@property (weak, nonatomic) IBOutlet VCTextField *emailField;
@property (weak, nonatomic) IBOutlet VCTextField *locationField;
@property (weak, nonatomic) IBOutlet VCTextField *driversLicenseField;
@property (weak, nonatomic) IBOutlet VCTextField *referralCodeField;

- (IBAction)didTapContinue:(id)sender;

@end

@implementation VCDriverCreateAccountViewController

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

- (IBAction)didTapContinue:(id)sender {
}
@end
