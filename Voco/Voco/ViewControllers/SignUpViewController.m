//
//  SignUpViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "SignUpViewController.h"
#import "VCTextField.h"
#import "VCUsersApi.h"
#import "VCValidation.h"
#import "WRUtilities.h"
#import "VCRiderHomeViewController.h"
#import "VCInterfaceModes.h"

#define kFirstNameFieldTag 1
#define kLastNameFieldTag 2
#define kPhoneFieldTag 3
#define kPasswordFieldTag 4
#define kEmailFieldTag 5
#define kReferralCodeFieldTag 6

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *firstNameField;
@property (weak, nonatomic) IBOutlet VCTextField *lastNameField;
@property (weak, nonatomic) IBOutlet VCTextField *phoneField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordField;
@property (weak, nonatomic) IBOutlet VCTextField *emailField;
@property (weak, nonatomic) IBOutlet VCTextField *referralCodeField;

- (IBAction)didTapSignUp:(id)sender;

@end

@implementation SignUpViewController

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
    [self signUp];
}

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kFirstNameFieldTag:
            [_lastNameField becomeFirstResponder];
            break;
        case kLastNameFieldTag:
            [_phoneField becomeFirstResponder];
            break;
        case kPhoneFieldTag:
            [_passwordField becomeFirstResponder];
            break;
        case kPasswordFieldTag:
            [_emailField becomeFirstResponder];
            break;
        case kEmailFieldTag:
            [_referralCodeField becomeFirstResponder];
            break;
        case kReferralCodeFieldTag:
            [self signUp];
            break;
    }
}

- (void) signUp {
    
    BOOL error = false;
    if (![VCValidation NSStringIsValidEmail:_emailField.text]){
        error = true;
        [_emailField setTextColor:[UIColor redColor]];
    }
    if(_phoneField.text == nil || [_phoneField.text isEqualToString:@""] ){
        error = true;
        [_phoneField setTextColor:[UIColor redColor]];
    }
    
    if(error == true){
         [UIAlertView showWithTitle:@"Error" message:@"" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    // Validations Pass
    [_emailField setTextColor:[UIColor blackColor]];


    
    [VCUsersApi createUser:[RKObjectManager sharedManager]
                      name:_firstNameField.text
                     email:_emailField.text
                  password:_passwordField.text
                     phone:_phoneField.text
              referralCode:_referralCodeField.text
                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                       
                       [UIAlertView showWithTitle:@"Registered!"
                                          message:@"Welcome to Voco"
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil
                                         tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                             [self login];
                                         }];
                       
                       
                   } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                       [WRUtilities criticalError:error];
                   }];
}

- (void) login {
    [VCUsersApi login:[RKObjectManager sharedManager] phone:_phoneField.text password:_passwordField.text
              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
 
                  [VCInterfaceModes showRiderInterface];
                  
              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                  [UIAlertView showWithTitle:@"Login Failed!" message:@"Invalid" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
              }];
}

@end
