//
//  VCOnboardingPersonalInfoViewController.m
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingPersonalInfoViewController.h"

@interface VCOnboardingPersonalInfoViewController ()

@property (strong, nonatomic) IBOutlet UITextField *onboardingFullNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *onboardingPhoneNumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *onboardingWorkEmailTextField;
- (IBAction)nextButtonTutorial:(id)sender;

@end

@implementation VCOnboardingPersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)nextButtonTutorial:(id)sender {
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
    
    NSString * firstName = parts[0];
    NSString * lastName = parts[1];

    NSDictionary * values = @{
                              FirstNameValueKey : firstName,
                              LastNameValueKey : lastName,
                              PhoneNumberValueKey : _onboardingFullNameTextField.text,
                              WorkEmailValueKey : _onboardingWorkEmailTextField.text,
                              };
    [self.delegate VCOnboardingChildViewController:self didSetValues:values];
    [self.delegate VCOnboardingChildViewControllerDidFinish:self];
}
@end
