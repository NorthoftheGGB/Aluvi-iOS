//
//  PasswordRecoveryViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCPasswordRecoveryViewController.h"
#import "VCTextField.h"
#import "VCValidation.h"
#import "VCUsersApi.h"
#import <MBProgressHUD.h>

#import "US2ConditionCollection.h"
#import "US2Condition.h"
#import "VCPhoneTextField.h"
#import "VCEmailTextField.h"

#define kPhoneFieldTag 1
#define kEmailFieldTag 2

@interface VCPasswordRecoveryViewController ()

@property (strong, nonatomic) IBOutlet VCTextField *phoneField;
@property (weak, nonatomic) IBOutlet VCTextField *emailField;
- (IBAction)didTapSendPassword:(id)sender;
- (IBAction)didEndOnExit:(id)sender;

@end

@implementation VCPasswordRecoveryViewController

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
        self.title = @"Password Recovery";
    
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

- (IBAction)didTapSendPassword:(id)sender {
    [self recoverEmail];
    
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
        case kPhoneFieldTag:
            if([_phoneField validate]){
                [_emailField becomeFirstResponder];
            }
            break;
        case kEmailFieldTag:
            if([_emailField validate]){
            [self recoverEmail];
            }
            break;
    }
}

- (void) recoverEmail{
    
    /*BOOL error = false;
    if (![VCValidation NSStringIsValidEmail:_emailField.text]){
        error = true;
        [_emailField setBackgroundColor:[UIColor redColor]];
        
    }
    
    if(error == true){
        [UIAlertView showWithTitle:@"Error" message:@"Some Fields Are Incorrect" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }*/
    
    
    if(![_phoneField validate]){
        return;
    }
    
    if(![_emailField validate]){
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Recovering Password";
    
    // Validation & server stuff
    
    [VCUsersApi forgotPassword:[RKObjectManager sharedManager]
                         email:_emailField.text
                         phone:_phoneField.text
                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                           [hud hide:YES];
                           [UIAlertView showWithTitle:@"Success"
                                              message:@"Your new password with be emailed to you"
                                    cancelButtonTitle: @"OK"
                                    otherButtonTitles:nil
                                             tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                 [self.navigationController popViewControllerAnimated:YES];
                                             }];
                       }
                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                           [hud hide:YES];
                           [UIAlertView showWithTitle:@"Error" message:@"Unable to reset your password.  Check your email and phone number" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                       }];
    
}


@end
