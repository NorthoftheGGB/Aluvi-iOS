//
//  PasswordRecoveryViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCPasswordRecoveryViewController.h"
#import "VCTextField.h"
#import "VCUsersApi.h"
#import <MBProgressHUD.h>

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

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kPhoneFieldTag:
            [_emailField becomeFirstResponder];
            break;
        case kEmailFieldTag:
            [self recoverEmail];
            break;
    }
}

- (void) recoverEmail{
    
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
