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
@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)didTapSubmit:(id)sender;


@end

@implementation VCDriverRequestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.showHamburger = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Driver Request";
    [self.scrollView setContentSize:_contentView.frame.size];
    [self.scrollView addSubview:_contentView];
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
            if([_firstNameField validate]){
                [_lastNameField becomeFirstResponder];
            }
            break;
        case kLastNameFieldTag:
            if([_lastNameField validate]){
                
                [_phoneField
                 becomeFirstResponder];
            }
            break;
        case kPhoneFieldTag:
            if([_phoneField validate]){
                [_emailField
                 becomeFirstResponder];
            }
            break;
        case kEmailFieldTag:
            if([_emailField validate]){
                [_referralCodeField
                 becomeFirstResponder];
            }
            break;
        case kReferralCodeFieldTag:
            [self driverRequest];
            break;
    }
}


- (void) driverRequest {
    
    if(![_firstNameField validate]){
        return;
    }
    
    if(![_lastNameField validate]){
        return;
    }
    
    if(![_phoneField validate]){
        return;
    }
    
    if(![_emailField validate]){
        return;
    }
    
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
