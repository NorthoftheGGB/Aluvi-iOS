//
//  SignUpViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCSignUpViewController.h"
#import "VCTextField.h"
#import "VCUsersApi.h"
#import "VCValidation.h"
#import "WRUtilities.h"
#import "VCRiderHomeViewController.h"
#import "VCInterfaceModes.h"
#import <MBProgressHUD.h>
#import "US2ConditionCollection.h"
#import "US2Condition.h"

#import "VCNameTextField.h"
#import "VCPhoneTextField.h"
#import "VCPasswordTextField.h"
#import "VCEmailTextField.h"
#import "VCReferralCodeTextField.h"

#define kFirstNameFieldTag 1
#define kLastNameFieldTag 2
#define kPhoneFieldTag 3
#define kPasswordFieldTag 4
#define kEmailFieldTag 5
#define kReferralCodeFieldTag 6

@interface VCSignUpViewController ()

@property (weak, nonatomic) IBOutlet VCNameTextField *firstNameField;
@property (weak, nonatomic) IBOutlet VCNameTextField *lastNameField;
@property (weak, nonatomic) IBOutlet VCPhoneTextField *phoneField;
@property (weak, nonatomic) IBOutlet VCPasswordTextField *passwordField;
@property (weak, nonatomic) IBOutlet VCEmailTextField *emailField;
@property (weak, nonatomic) IBOutlet VCReferralCodeTextField *referralCodeField;
@property (strong, nonatomic) MBProgressHUD *hud;


- (IBAction)didTapSignUp:(id)sender;

@end

@implementation VCSignUpViewController

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
    self.title = @"Sign Up";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSignUp:(id)sender {
    [self signUp];
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
        case kFirstNameFieldTag:
            if([_firstNameField validate]){
            [_lastNameField becomeFirstResponder];
            }
            break;
        case kLastNameFieldTag:
            if([_lastNameField validate]){
            [_phoneField becomeFirstResponder];
            }
            break;
        case kPhoneFieldTag:
            if([_phoneField validate]){
                [_passwordField becomeFirstResponder];
            }
            break;
        case kPasswordFieldTag:
            if([_passwordField validate]){
            [_emailField becomeFirstResponder];
            }
            break;
        case kEmailFieldTag:
            if([_emailField validate]){
                [_referralCodeField becomeFirstResponder];
            }
            break;
        case kReferralCodeFieldTag:
            if([_referralCodeField validate]){
            [self signUp];
            }
            break;
    }
}



- (void) signUp {
    
    /*
     BOOL error = false;
     if (![VCValidation NSStringIsValidEmail:_emailField.text] || _emailField.text == nil || [_emailField.text isEqualToString:@""]){
     error = true;
     [_emailField setBackgroundColor:[UIColor redColor]];
     }
     
     if(_phoneField.text == nil || [_phoneField.text isEqualToString:@""] ){
     error = true;
     [_phoneField setBackgroundColor:[UIColor redColor]];
     }
     
     if (_passwordField.text == nil || [_passwordField.text isEqualToString:@""]){
     error = true;
     [_passwordField setBackgroundColor:[UIColor redColor]];
     }
     
     if (_firstNameField.text == nil || [_firstNameField.text isEqualToString:@""]){
     error = true;
     [_firstNameField setBackgroundColor:[UIColor redColor]];
     }
     
     
     if (_lastNameField.text == nil || [_lastNameField.text isEqualToString:@""]){
     error = true;
     [_lastNameField setBackgroundColor:[UIColor redColor]];
     }
     
     if(error == true){
     [UIAlertView showWithTitle:@"Error" message:@"" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
     return;
     }
     */
    
    if(![_firstNameField validate]){
        return;
    }
    
    if(![_lastNameField validate]){
        return;
    }
    
    if(![_phoneField validate]){
        return;
    }
    
    if(![_passwordField validate]){
        return;
    }
    
    if(![_emailField validate]){
        return;
    }
    
    if(![_referralCodeField validate]){
        return;
    }
    
    // Validations Pass
    //[_emailField setTextColor:[UIColor blackColor]];
    
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // _hud.labelText = @"Signing Up";
    
    [VCUsersApi createUser:[RKObjectManager sharedManager]
                 firstName:_firstNameField.text
                  lastName:_lastNameField.text
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
                  
                  [[VCInterfaceModes instance] showRiderInterface];
                  
              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                  [UIAlertView showWithTitle:@"Login Failed!" message:@"Invalid" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
              }];
}

@end
