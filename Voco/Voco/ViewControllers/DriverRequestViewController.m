//
//  DriverRequestViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "DriverRequestViewController.h"
#import "VCTextField.h"
#import "VCUsersApi.h"
#import "VCValidation.h"


#define kFirstNameFieldTag 1
#define kLastNameFieldTag 2
#define kPhoneFieldTag 3
#define kEmailFieldTag 4
#define kReferralCodeFieldTag 5

@interface DriverRequestViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *firstNameField;
@property (weak, nonatomic) IBOutlet VCTextField *lastNameField;
@property (weak, nonatomic) IBOutlet VCTextField *phoneField;
@property (weak, nonatomic) IBOutlet VCTextField *emailField;
@property (weak, nonatomic) IBOutlet VCTextField *referralCodeField;

- (IBAction)didTapSubmit:(id)sender;


@end

@implementation DriverRequestViewController

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

- (IBAction)didTapSubmit:(id)sender {
    [self driverRequest];
}

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kFirstNameFieldTag:
            [_lastNameField
             becomeFirstResponder];
            break;
        case kLastNameFieldTag:
            [_phoneField
             becomeFirstResponder];
            break;
        case kPhoneFieldTag:
            [_emailField
             becomeFirstResponder];
            break;
        case kEmailFieldTag:
            [_referralCodeField
             becomeFirstResponder];
            break;
        case kReferralCodeFieldTag:
            [self driverRequest];
            break;
    }
}


- (void) driverRequest {
    
    BOOL error = false;
    if (![VCValidation NSStringIsValidEmail:_emailField.text]){
        error = true;
        [UIAlertView showWithTitle:@"Error" message:@"Invalid Email Address" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        [_emailField setTextColor:[UIColor redColor]];
    }
    
    if(error == true){
        return;
    }

    
    [VCUsersApi driverInterested:[RKObjectManager sharedManager] name:_firstNameField.text email:_emailField.text region:@"Default" phone:_phoneField.text driverReferralCode:_referralCodeField.text
                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             [UIAlertView showWithTitle:@"Success" message:@"We will contact you about driving" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                 [self.navigationController popViewControllerAnimated:YES];
                             }];
                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                             [WRUtilities criticalError:error];
                         }];
}
@end
