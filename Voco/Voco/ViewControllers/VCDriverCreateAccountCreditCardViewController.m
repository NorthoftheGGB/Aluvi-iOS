//
//  VCDriverCreateAccountCreditCardViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverCreateAccountCreditCardViewController.h"
#import "VCTextField.h"

@interface VCDriverCreateAccountCreditCardViewController ()
@property (weak, nonatomic) IBOutlet VCTextField *accountNameField;
@property (weak, nonatomic) IBOutlet VCTextField *accountNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *routingNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *brandField;
@property (weak, nonatomic) IBOutlet VCTextField *modelField;
@property (weak, nonatomic) IBOutlet VCTextField *yearField;
@property (weak, nonatomic) IBOutlet VCTextField *licensePlateField;
@property (weak, nonatomic) IBOutlet UIView *checkboxOutlet;

- (IBAction)didTapTermsOfService:(id)sender;
- (IBAction)didTapContinue:(id)sender;

@end

@implementation VCDriverCreateAccountCreditCardViewController

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

- (IBAction)didTapTermsOfService:(id)sender {
}

- (IBAction)didTapAgree:(id)sender {
}

- (IBAction)didTapContinue:(id)sender {
}
@end
