//
//  VCLogInViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLogInViewController.h"
#import <MBProgressHUD.h>
#import "US2ConditionEmail.h"
#import "US2Validator.h"
#import "VCUserStateManager.h"
#import "VCInterfaceManager.h"
#import "VCCommuteManager.h"
#import "VCRidesApi.h"
#import "VCTextField.h"
#import "VCButtonBold.h"
#import "VCButton.h"
#import "VCPasswordRecoveryViewController.h"
#import "VCNotifications.h"
#import <QuartzCore/QuartzCore.h>
#import "DTHTMLAttributedStringBuilder.h"
#import "DTCoreTextConstants.h"
#import "VCOnBoardingViewController.h"
#import "VCEmailTextField.h"
#import "VCCodes.h"
#import "VCOnboardingSetRouteViewController.h"

#define kPhoneFieldTag 1
#define kPasswordFieldTag 2


@interface VCLogInViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet VCButtonBold *logInButton;
@property (weak, nonatomic) IBOutlet VCButtonBold *createAccountButton;

@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *modeToggleButton;
@property (strong, nonatomic) NSAttributedString * attributedString;
@property (strong, nonatomic) MBProgressHUD * hud;

@property BOOL mode;

- (IBAction)didTapLogIn:(id)sender;
- (IBAction)didTapCreateAccount:(id)sender;

- (IBAction)didTapForgotPassword:(id)sender;
//- (IBAction)didTapTermsAndConditions:(id)sender;
- (IBAction)didTapModeToggleButton:(id)sender;


@end

@implementation VCLogInViewController

@dynamic delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadTermsOfService];
        _mode = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
#ifndef RELEASE
    UISwipeGestureRecognizer * shortCut = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(debug:)];
    [shortCut setNumberOfTouchesRequired:2];
    [shortCut setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:shortCut];
#endif
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    UIImage * blankImage = [UIImage imageNamed:@"nav-bar-background"];
    [self.navigationController.navigationBar setBackgroundImage:blankImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:blankImage];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.view setBackgroundColor: [UIColor clearColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

#ifdef SPOOF
    _emailTextField.text = [NSString stringWithFormat: @"%@gg@gg.com", [NSDate date]];
    _passwordTextField.text = @"gg";
#endif
    
    // Set up some validation
    US2ConditionEmail *emailCondition = [[US2ConditionEmail alloc] init];
    US2Validator *validator = [[US2Validator alloc] init];
    [validator addCondition:emailCondition];
    _emailTextField.validator = validator;
    _emailTextField.fieldName = @"Email";
}


- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}

- (void) debug:(id) sender {
    
    
    NSArray * userEmails = [NSArray array];
    NSArray * passwords = [NSArray array];
    NSArray * userLabels = [NSArray array];
    
#ifdef TESTING
        NSString * newUserEmail = [NSString stringWithFormat:@"%f@z.com", [[NSDate date] timeIntervalSince1970] ];
    userEmails = @[ @"v1@vocotransportation.com", @"v3@vocotransportation.com", newUserEmail];
    passwords = @[ @"abc123456", @"abc123456", @"1111111111" ];
    userLabels = @[ @"rider", @"driver", @"new user"];
#elif ALPHA
    
#else
    NSString * newUserEmail = [NSString stringWithFormat:@"%f@z.com", [[NSDate date] timeIntervalSince1970] ];
    userEmails = @[ @"v1@vocotransportation.com", @"v3@vocotransportation.com", newUserEmail];
    passwords = @[ @"9999999999", @"5555555555", @"1111111111" ];
    userLabels = @[  @"rider", @"driver", @"new user"];
#endif
    
    
    [UIAlertView showWithTitle:@"Debug" message:@"Log In?" cancelButtonTitle:@"No" otherButtonTitles:userLabels tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if(buttonIndex == 0) {
            
        } else if(buttonIndex <= [userEmails count]){
            _emailTextField.text = [userEmails objectAtIndex:buttonIndex-1];
            _passwordTextField.text = [passwords objectAtIndex:buttonIndex-1];
            [self login];
        } else {
            
        }
        
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapLogIn:(id)sender {
    _emailTextField.text = [_emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
    [self login];
}

- (IBAction)didTapCreateAccount:(id)sender {
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    if([_emailTextField.text length] == 0 || [_passwordTextField.text length] == 0){
        [UIAlertView showWithTitle:@"Username/Password" message:@"Please fill in your desired email and password" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }

    
    _emailTextField.text = [_emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(![_emailTextField validate]){
        return;
    }
    
    if(![_passwordTextField validate]){
        return;
    }
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"Checking Email...";
    [[VCUserStateManager instance] loginWithEmail:_emailTextField.text
                                         password:_passwordTextField.text
                                          success:^{
                                              
                                              [UIAlertView showWithTitle:@"Already Registered" message:@"That email address is already registered with Aluvi, do you want to complete logging in?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  switch(buttonIndex){
                                                      case 0:
                                                      {
                                                          [[VCUserStateManager instance] logoutWithCompletion:^{
                                                              [_hud hide:YES];
                                                          }];
                                                      }
                                                          break;
                                                          
                                                      case 1:
                                                      {
                                                          _hud.labelText = @"Logging in...";
                                                          [self completeLogin];
                                                      }
                                                          break;
                                                          
                                                      default:
                                                          break;
                                                  }
                                              }];
                                              
                                          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                              
                                              _hud.hidden = YES;
                                              
                                              switch (operation.HTTPRequestOperation.response.statusCode) {
                                                  case 404:
                                                  {
                                                      [self goToSignUp];
                                                  }
                                                      break;
                                                      
                                                  case 403:
                                                      [UIAlertView showWithTitle:@"Already Registered" message:@"That email is already in our system, but your password is incorrect" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                                      break;
                                                      
                                                  default:
                                                      break;
                                              }
                                          }];
    
    
    
    /*
     [UIAlertView showWithTitle:@"Sign Up For Aluvi" message:@"To gain access to the application please visit our website." cancelButtonTitle:@"Not Now" otherButtonTitles:@[@"Take me there"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
     switch (buttonIndex) {
     case 1:
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.aluviapp.com/"]];
     break;
     
     default:
     break;
     }
     }];
     */
}

- (void) login {
    
    
    if(![_emailTextField validate]){
        return;
    }
    
    if(![_passwordTextField validate]){
        return;
    }
    
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"Logging In";
    
    [[VCUserStateManager instance] loginWithEmail:_emailTextField.text
                                         password:_passwordTextField.text
                                          success:^{
                                              [self completeLogin];
                                              
                                          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                              
                                              
                                              switch (operation.HTTPRequestOperation.response.statusCode) {
                                                  case 404:
                                                  {
                                                      [UIAlertView showWithTitle:@"New User?"
                                                                         message:@"The email you provided was not found. Click 'Register' to join Aluvi."
                                                               cancelButtonTitle:@"Cancel"
                                                               otherButtonTitles:@[@"Register"]
                                                                        tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                            switch(buttonIndex){
                                                                                case 1:
                                                                                    [self goToSignUp];
                                                                                    break;
                                                                                default:
                                                                                    break;
                                                                            }
                                                                        }];
                                                  }
                                                      break;
                                                      
                                                  case 401:
                                                      [UIAlertView showWithTitle:@"Incorrect Password" message:@"That's not the correct password for this email address, how about trying again." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                                      break;
                                                      
                                                  default:
                                                      [WRUtilities criticalError:error];
                                                      [UIAlertView showWithTitle:@"Login Failed!" message:@"We had a problem talking with the server.  Please try again.  " cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                                      break;
                                              }
                                              [_hud hide:YES];
                                              
                                              
                                          }];
    
    
}

- (void) completeLogin {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSkipTutorial];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[VCCommuteManager instance] refreshTicketsWithSuccess:^{
        [_hud hide:YES];
        [[VCInterfaceManager instance] showRiderInterface];
        [VCNotifications scheduleUpdated];

    } failure:^{
        [_hud hide:YES];

    }];
}

- (void) goToSignUp {
    
#if 1
    
    NSDictionary * values = @{
                              EmailValueKey : _emailTextField.text,
                              PasswordValueKey : _passwordTextField.text
                              };
    [self.delegate VCOnboardingChildViewController:self didSetValues:values];
    [self.delegate VCOnboardingChildViewControllerDidFinish:self];

#else
    
    [UIAlertView showWithTitle:@"Confirmation Code"
                       message:@"Please enter your confirmation code, or register online to recieve one."
                         style:UIAlertViewStylePlainTextInput cancelButtonTitle:@"Cancel"
             otherButtonTitles:@[@"Submit", @"Register Online" ]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          switch (buttonIndex) {
                              case 1:
                              {
                                  UITextField * textField = [alertView textFieldAtIndex:0];
                                  [textField resignFirstResponder];
                                  if( [VCCodes checkCode:textField.text] ){
                                      
                                      // Good to do, email is not in the system
                                      VCRiderOnBoardingViewController * vc = [[VCRiderOnBoardingViewController alloc] init];
                                      vc.desiredEmail = _emailTextField.text;
                                      vc.desiredPassword = _passwordTextField.text;
                                      vc.termsOfServiceString = _attributedString;
                                      [self.navigationController pushViewController:vc animated:YES];
                                      
                                  } else {
                                      
                                      [UIAlertView showWithTitle:@"Invalid Code"
                                                         message:@"We couldn't verify that code, do you want to try again?  If you don't have a code, please register to recieve one"
                                               cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Try Again", @"Register For Code"]
                                                        tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                            switch (buttonIndex) {
                                                                case 1:
                                                                    [self goToSignUp];
                                                                    break;
                                                                    
                                                                case 2:
                                                                    [self registerOnline];
                                                                    break;
                                                                    
                                                                default:
                                                                    break;
                                                            }
                                                        }];
                                  }
                              }
                                  break;
                              case 2:
                                  [self registerOnline];
                                  break;
                                  
                              default:
                                  break;
                          }
                      }];
    
#endif

}

- (void) registerOnline {
    //VCBetaRegisterViewController * vc = [[VCBetaRegisterViewController alloc] init];
    //[self.navigationController presentViewController:vc animated:YES completion:nil];
}


- (IBAction)didTapForgotPassword:(id)sender {
    VCPasswordRecoveryViewController * passwordRecoveryViewController = [[VCPasswordRecoveryViewController alloc] init];
    [self.delegate VCOnboardingChildViewController:self didRequestPushController:passwordRecoveryViewController];
    
}

- (IBAction)didTapModeToggleButton:(id)sender {
    if (_mode == YES){
        _mode = NO;
    } else {
        _mode = YES;
    }

    if (_mode == NO){
        [UIView transitionWithView:self.view
                          duration:0.33f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.logInButton.hidden = NO;
                            self.forgotPasswordButton.hidden = NO;
                            self.createAccountButton.hidden = YES;
                            [self.modeToggleButton setTitle:@"Or, create an account" forState: UIControlStateNormal];

                        } completion:NULL];
        
    }
    
    else {
        [UIView transitionWithView:self.view
                          duration:0.33f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{

        self.logInButton.hidden = YES;
        self.forgotPasswordButton.hidden = YES;
        self.createAccountButton.hidden = NO;
        [self.modeToggleButton setTitle:@"Or, Log In" forState: UIControlStateNormal];
                              } completion:NULL];
    }
}



- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    if([textField.text length] > 0){
        textField.backgroundColor = [UIColor whiteColor];
    }
    switch(textField.tag){
        case kPhoneFieldTag:
            _emailTextField.text = [_emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
- (IBAction)didTapTemsOfServiceLinkButton:(id)sender {
}
@end
