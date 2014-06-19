//
//  VCDriverCreateAccountCreditCardViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverRegistrationViewController.h"
#import "VCTextField.h"

@interface VCDriverRegistrationViewController ()
@property (weak, nonatomic) IBOutlet VCTextField *accountNameField;
@property (weak, nonatomic) IBOutlet VCTextField *accountNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *routingNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *brandField;
@property (weak, nonatomic) IBOutlet VCTextField *modelField;
@property (weak, nonatomic) IBOutlet VCTextField *yearField;
@property (weak, nonatomic) IBOutlet VCTextField *licensePlateField;
@property (weak, nonatomic) IBOutlet UIView *checkboxOutlet;
@property (weak, nonatomic) IBOutlet VCTextField *driversLicenseField;
@property (weak, nonatomic) IBOutlet UITextField *referralCodeField;
@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)didTapTermsOfService:(id)sender;
- (IBAction)didTapContinue:(id)sender;

@end

@implementation VCDriverRegistrationViewController

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
    
    [self.scrollView setContentSize:_contentView.frame.size];
    [self.scrollView addSubview:_contentView];
#if RELEASE==1
    _accountNumberField.text = @"000123456789";
    _routingNumberField.text = @"110000000";
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapTermsOfService:(id)sender {
}

- (IBAction)didTapAgree:(id)sender {
}

- (IBAction)didTapContinue:(id)sender {
}
@end
