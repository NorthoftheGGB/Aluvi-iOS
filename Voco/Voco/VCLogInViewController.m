//
//  VCLogInViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLogInViewController.h"
#import <MBProgressHUD.h>
#import "VCUserStateManager.h"
#import "VCInterfaceManager.h"
#import "VCRiderApi.h"
#import "VCTextField.h"
#import "VCButtonStandardStyle.h"
#import "VCPasswordRecoveryViewController.h"
#import "VCTermsOfServiceViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DTHTMLAttributedStringBuilder.h"
#import "DTCoreTextConstants.h"

#define kPhoneFieldTag 1
#define kPasswordFieldTag 2

@interface VCLogInViewController ()
@property (weak, nonatomic) IBOutlet VCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (strong, nonatomic) NSAttributedString * attributedString;

- (IBAction)didTapSignIn:(id)sender;
- (IBAction)didTapSignUP:(id)sender;

- (IBAction)didTapForgotPassword:(id)sender;
- (IBAction)didTapTermsAndConditions:(id)sender;

@end

@implementation VCLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadTermsOfService];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

/*
- (void) viewWillAppear:(BOOL)animated {
    [UIAlertView showWithTitle:@"title" message:@"mess" cancelButtonTitle:@"ok" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        NSLog(@"hi %@", @"hi");
    }];
}
*/


- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSignIn:(id)sender {
    [self login];
}

- (IBAction)didTapSignUP:(id)sender {
    [UIAlertView showWithTitle:@"Sign Up For Aluvi" message:@"To gain access to the application please visit our website." cancelButtonTitle:@"Not Now" otherButtonTitles:@[@"Take me there"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.aluviapp.com/"]];
                break;
                
            default:
                break;
        }
    }];
}

- (void) login {
    
    
    if(![_emailTextField validate]){
        return;
    }
    
    if(![_passwordTextField validate]){
        return;
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging In";
    
    [[VCUserStateManager instance] loginWithEmail:_emailTextField.text
                                         password:_passwordTextField.text
                                          success:^{
                                              
                                              [VCRiderApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  [hud hide:YES];
                                                  [[VCInterfaceManager instance] showRiderInterface];
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  [WRUtilities criticalError:error];
                                                  [hud hide:YES];
                                                  
                                              }];
                                              
                                          } failure:^{
                                              [hud hide:YES];
                                              [UIAlertView showWithTitle:@"Login Failed!" message:@"Invalid Email or Password.  " cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                          }];
    
    
}


- (IBAction)didTapForgotPassword:(id)sender {
    VCPasswordRecoveryViewController * passwordRecoveryViewController = [[VCPasswordRecoveryViewController alloc] init];
    [self.navigationController pushViewController:passwordRecoveryViewController animated:YES];
    
}

- (IBAction)didTapTermsAndConditions:(id)sender {
    
    VCTermsOfServiceViewController * vc = [[VCTermsOfServiceViewController alloc] init];
    if(_attributedString == nil){
        // This probably won't still be nil by now, but just in case..
        [self loadTermsOfService];
    }
    vc.termsOfServiceString = _attributedString;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    if([textField.text length] > 0){
        textField.backgroundColor = [UIColor whiteColor];
    }
    
    switch(textField.tag){
        case kPhoneFieldTag:
            if ([_emailTextField validate]){
                [_passwordTextField becomeFirstResponder];
            }
            break;
        case kPasswordFieldTag:
            if([_passwordTextField validate]) {
                [self.view endEditing:YES];
                [self login];
            }
            break;
    }
}


- (void) loadTermsOfService {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Aluvi-TOS" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    
    // Set our builder to use the default native font face and size
    NSDictionary *builderOptions = @{
                                     DTDefaultFontFamily: @"Helvetica",
                                     DTDefaultTextColor: @"Black",
                                     DTUseiOS6Attributes: @YES
                                     };
    
    DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:htmlData
                                                                                               options:builderOptions
                                                                                    documentAttributes:nil];
    _attributedString = [stringBuilder generatedAttributedString];
}
@end
