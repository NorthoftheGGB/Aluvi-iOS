//
//  VCRiderOnBoardingViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderOnBoardingViewController.h"
#import <Stripe.h>
#import <STPView.h>
#import <MBProgressHUD.h>
#import <UIAlertView+Blocks.h>
#import "VCTextField.h"
#import "VCButtonStandardStyle.h"
#import "VCUsersApi.h"
#import "VCRiderApi.h"
#import "Payment.h"
#import "VCUtilities.h"
#import "VCValidation.h"


 #define kFirstNameFieldTag 1
 #define kLastNameFieldTag 2
 #define kPhoneFieldTag 3
 #define kZipCodeFieldTag 4

@interface VCRiderOnBoardingViewController () <STPViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *STPViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *cardInfoLabel;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet VCTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet VCTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet VCTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet VCTextField *zipCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *tocButton;
@property (weak, nonatomic) IBOutlet UIButton *tocCheckBoxButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *nextButton;


- (IBAction)didTapTocButton:(id)sender;

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

- (IBAction)didTapTocCheckBoxButton:(id)sender {
}

- (IBAction)didTapNextButton:(id)sender {
}
- (IBAction)didTapTocButton:(id)sender {
    if (_tocCheckBoxButton.selected == YES){
        _tocCheckBoxButton.selected = NO;
        
    }
}




/*
//TODO: clean up validation in this code
 
- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kFirstNameFieldTag:
            if([_firstNameTextField validate]){
                [_lastNameTextField becomeFirstResponder];
            }
            break;
 
        case kLastNameTextFieldTag:
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
        
        BOOL error = false;
        if (![VCValidation NSStringIsValidEmail:_emailField.text]){
            error = true;
            [UIAlertView showWithTitle:@"Error" message:@"Invalid Email Address" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            [_emailField setTextColor:[UIColor redColor]];
        }
        
        if(error == true){
            return;
        }
    }
 */

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    // Enable the "save" button only if the card form is complete.
    
    //TODO: fix this
    if(valid){
        //_updateCardButton.enabled = YES;
    } else {
       // _updateCardButton.enabled = NO;
        
    }

}
@end
