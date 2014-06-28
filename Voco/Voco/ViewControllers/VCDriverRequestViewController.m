//
//  DriverRequestViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverRequestViewController.h"
#import "VCTextField.h"
#import "VCUsersApi.h"
#import "VCValidation.h"
#import <MBProgressHUD.h>

#define kFirstNameFieldTag 1
#define kLastNameFieldTag 2
#define kPhoneFieldTag 3
#define kEmailFieldTag 4
#define kReferralCodeFieldTag 5

@interface VCDriverRequestViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *firstNameField;
@property (weak, nonatomic) IBOutlet VCTextField *lastNameField;
@property (weak, nonatomic) IBOutlet VCTextField *phoneField;
@property (weak, nonatomic) IBOutlet VCTextField *emailField;
@property (weak, nonatomic) IBOutlet VCTextField *referralCodeField;

- (IBAction)didTapSubmit:(id)sender;


@end

@implementation VCDriverRequestViewController

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
    self.title = @"Driver Request";    
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

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Submitting Request";
    
    [VCUsersApi driverInterested:[RKObjectManager sharedManager] name:_firstNameField.text email:_emailField.text region:@"Default" phone:_phoneField.text driverReferralCode:_referralCodeField.text
                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             
                             [hud hide:YES];
                             [UIAlertView showWithTitle:@"Success" message:@"We will contact you about driving" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                 [self.navigationController popViewControllerAnimated:YES];
                             }];
                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                             [hud hide:YES];
                             [WRUtilities criticalError:error];
                         }];
}
@end
