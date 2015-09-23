//
//  VCOnboardingPersonalInfoViewController.m
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingPersonalInfoViewController.h"
#import "US2ConditionEmail.h"
#import "US2Validator.h"
#import "VCTextField.h"

#define kFullNameField 1
#define kPhoneNumberField 2
#define kWorkEmailField 3


@interface VCOnboardingPersonalInfoViewController ()

@property (strong, nonatomic) IBOutlet UITextField *onboardingFullNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *onboardingPhoneNumberTextField;
@property (strong, nonatomic) IBOutlet VCTextField *onboardingWorkEmailTextField;
- (IBAction)nextButtonTutorial:(id)sender;

@end

@implementation VCOnboardingPersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef SPOOF
    _onboardingFullNameTextField.text = @"ng ng";
    _onboardingPhoneNumberTextField.text = @"9876787656";
    _onboardingWorkEmailTextField.text = @"asdf@asdf.com";
#endif
    
    // Set up some validation
    US2ConditionEmail *emailCondition = [[US2ConditionEmail alloc] init];
    US2Validator *validator = [[US2Validator alloc] init];
    [validator addCondition:emailCondition];
    _onboardingWorkEmailTextField.validator = validator;
    _onboardingWorkEmailTextField.fieldName = @"Work Email";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) complete {
    // validation
    NSArray * parts = [_onboardingFullNameTextField.text componentsSeparatedByString:@" "];
    if([parts count] < 2){
        [UIAlertView showWithTitle:@"Error" message:@"Please enter a first and a last name" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    if(_onboardingPhoneNumberTextField.text == nil){
        [UIAlertView showWithTitle:@"Error" message:@"Phone number is required so that we can make sure you get to work" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    if(_onboardingWorkEmailTextField.text == nil){
        [UIAlertView showWithTitle:@"Error" message:@"Work email is required for commuter compensation" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    
    NSError *error             = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"['a-zA-Z\\s]" options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:_onboardingFullNameTextField.text options:0 range:NSMakeRange(0, _onboardingFullNameTextField.text.length)];
    
    if(numberOfMatches != _onboardingFullNameTextField.text.length){
        [UIAlertView showWithTitle:@"Error" message:@"Please enter only valid characters in your name" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    error             = NULL;
    regex = [NSRegularExpression regularExpressionWithPattern: @"[0-9]" options:0 error:&error];
    numberOfMatches = [regex numberOfMatchesInString:_onboardingPhoneNumberTextField.text options:0 range:NSMakeRange(0, _onboardingPhoneNumberTextField.text.length)];
    if(numberOfMatches != _onboardingPhoneNumberTextField.text.length){
        [UIAlertView showWithTitle:@"Error" message:@"Please enter only numbers for your phone number" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    if([_onboardingPhoneNumberTextField.text length] != 10){
        [UIAlertView showWithTitle:@"Error" message:@"Phone number should be exactly ten numerals" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    if(_onboardingWorkEmailTextField.text != nil && ![_onboardingWorkEmailTextField.text isEqualToString:@""]){
        if(![_onboardingWorkEmailTextField validate]){
            return;
        }
    }
    
    
    NSString * firstName = parts[0];
    NSString * lastName = parts[1];
    
    NSDictionary * values = @{
                              FirstNameValueKey : firstName,
                              LastNameValueKey : lastName,
                              PhoneNumberValueKey : _onboardingPhoneNumberTextField.text,
                              WorkEmailValueKey : _onboardingWorkEmailTextField.text,
                              };
    [self.delegate VCOnboardingChildViewController:self didSetValues:values];
    [self.delegate VCOnboardingChildViewControllerDidFinish:self];
}


- (IBAction)nextButtonTutorial:(id)sender {
    [self complete];
}

- (IBAction)didEndOnExit:(id)sender {
    UITextField * textField = sender;
    switch (textField.tag) {
        case kFullNameField:
            [_onboardingPhoneNumberTextField becomeFirstResponder];
            break;
        case kPhoneNumberField:
            [_onboardingWorkEmailTextField becomeFirstResponder];
            break;
        case kWorkEmailField:
            [self complete];
            break;
            
        default:
            break;
    }
    [sender resignFirstResponder];

}


@end
