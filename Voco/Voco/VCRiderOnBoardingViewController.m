//
//  VCRiderOnBoardingViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderOnBoardingViewController.h"
#import <Stripe.h>
#import <PTKView.h>
#import <PTKTextField.h>
#import <MBProgressHUD.h>
#import <UIAlertView+Blocks.h>
#import "VCTextField.h"
#import "VCButtonStandardStyle.h"
#import "VCUsersApi.h"
#import "VCRiderApi.h"
#import "Payment.h"
#import "VCUtilities.h"
#import "VCValidation.h"
#import "VCDriverOnBoardingViewController.h"
#import <A2DynamicDelegate.h>
#import "VCUserStateManager.h"

#define kFirstNameFieldTag 1
#define kLastNameFieldTag 2
#define kPhoneFieldTag 3
#define kZipCodeFieldTag 4

@interface VCRiderOnBoardingViewController () <PTKViewDelegate>
@property (strong, nonatomic) PTKView * cardView;
@property (weak, nonatomic) IBOutlet UIView *PTKViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *cardInfoLabel;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet VCTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet VCTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet VCTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet VCTextField *zipCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *tocButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *privatePolicyButton;
@property (weak, nonatomic) IBOutlet UITextView *termsOfServices;

@property (weak, nonatomic) IBOutlet UIButton *tocCheckBoxButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *nextButton;

@property (strong, nonatomic) MBProgressHUD * hud;

- (IBAction)didTapTocButton:(id)sender;
- (IBAction)didTapPrivatePolicyButton:(id)sender;

- (IBAction)didTapTocCheckBoxButton:(id)sender;

- (IBAction)didTapNextButton:(id)sender;
@end

@implementation VCRiderOnBoardingViewController

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
    self.title = @"Rider Sign Up";
    [self.scrollView setContentSize:_contentView.frame.size];
    [self.scrollView addSubview:_contentView];
    
    _termsOfServices.attributedText = _termsOfServiceString;
    
    _cardView = [[PTKView alloc] initWithFrame:CGRectMake(15,20,290,55)];
    _cardView.delegate = self;
    
    [_PTKViewContainer addSubview:_cardView];
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    
#ifndef RELEASE
    UISwipeGestureRecognizer * shortCut = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(debug:)];
    [shortCut setNumberOfTouchesRequired:2];
    [shortCut setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:shortCut];
#endif
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_firstNameTextField becomeFirstResponder];
}

- (void) debug:(id)sender {
    _firstNameTextField.text = @"Mattar";
    _lastNameTextField.text = @"Paneer";
    _phoneTextField.text = @"1234567890";
    _zipCodeTextField.text = @"06511";
    _cardView.cardNumberField.text = @"5555555555554444";
    _cardView.cardExpiryField.text = @"12/19";
    _cardView.cardCVCField.text = @"234";
}

- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapTocCheckBoxButton:(id)sender {
    if (_tocCheckBoxButton.selected == YES){
        _tocCheckBoxButton.selected = NO;
    } else {
        _tocCheckBoxButton.selected = YES;
    }
}

- (IBAction)didTapNextButton:(id)sender {
    [self riderOnBoarding];
}
- (IBAction)didTapTocButton:(id)sender {
    // Launch TOC in modal
}

- (IBAction)didTapPrivatePolicyButton:(id)sender {
    // Launch privacy policy in modal
}





//TODO: clean up validation in this code

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kFirstNameFieldTag:
            if([_firstNameTextField validate]){
                [_lastNameTextField becomeFirstResponder];
            }
            break;
            
        case kLastNameFieldTag:
            if([_lastNameTextField validate]){
                [_phoneTextField
                 becomeFirstResponder];
            }
            break;
            
        case kPhoneFieldTag:
            if([_phoneTextField validate]){
                [_zipCodeTextField
                 becomeFirstResponder];
            }
            break;
            
        case kZipCodeFieldTag:
            if([_zipCodeTextField validate]){  //set up Zip Validation
                [sender resignFirstResponder];
            }
            break;
    }
    
}

- (void) riderOnBoarding {
    
    if(![_firstNameTextField validate]){
        return;
    }
    
    if(![_lastNameTextField validate]){
        return;
    }
    
    if(![_phoneTextField validate]){
        return;
    }
    
    if(![_zipCodeTextField validate]){
        return;
    }
    
    if(_tocCheckBoxButton.selected != YES){
        [UIAlertView showWithTitle:@"Error"
                           message:@"You must accept the terms and conditions"
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:nil];
        return;
    }
    
    STPCard *card = [[STPCard alloc] init];
    card.number = _cardView.card.number;
    card.expMonth = _cardView.card.expMonth;
    card.expYear = _cardView.card.expYear;
    card.cvc = _cardView.card.cvc;
    
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"Saving user info";
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error == nil ) {
            [VCUsersApi createUser:[RKObjectManager sharedManager]
                         firstName:_firstNameTextField.text
                          lastName:_lastNameTextField.text
                             email:_desiredEmail
                          password:_desiredPassword
                             phone:_phoneTextField.text
                      referralCode:@""
                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                               
                               [[VCUserStateManager instance] loginWithEmail:_desiredEmail
                                                                    password:_desiredPassword success:^{
                                                                        [VCUsersApi updateDefaultCard:[RKObjectManager sharedManager]
                                                                                            cardToken:token.tokenId
                                                                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                                  
                                                                                                  [self nextPage];
                                                                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                                  [self somethingDidNotGoRight];
                                                                                                  [WRUtilities criticalError:error];
                                                                                                  
                                                                                              }];
                                                                        
                                                                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                        [self somethingDidNotGoRight];
                                                                        [WRUtilities criticalError:error];
                                                                    }];
                               
                           } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                               [self somethingDidNotGoRight];
                               [WRUtilities criticalError:error];
                               
                               
                           }];
        } else {
            [self somethingDidNotGoRight];
#ifdef DEBUG
            [WRUtilities criticalError:error];
#endif
        }
    }];
}

- (void) somethingDidNotGoRight {
    _hud.hidden = YES;
    [WRUtilities subcriticalErrorWithString:@"Something didn't go right.  Want to try that again?"];
    
}

- (void) nextPage {
    VCDriverOnBoardingViewController * vc = [[VCDriverOnBoardingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    // Enable the "save" button only if the card form is complete.
    if(valid){
        _nextButton.enabled = YES;
        [_cardView resignFirstResponder];
    } else {
        _nextButton.enabled = NO;
    }
    
}

- (void)paymentViewDidStartEditing:(PTKView *)paymentView {
    self.scrollFocusView = _PTKViewContainer;
}

@end
