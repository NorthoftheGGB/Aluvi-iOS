//
//  VCOnboardingPersonalInfoViewController.h
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCOnboardingPersonalInfoViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *onboardingFullNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *onboardingPhoneNumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *onboardingWorkEmailTextField;




- (IBAction)onboardingFullNameTextField:(id)sender;
- (IBAction)onboardingPhoneNumberTextField:(id)sender;
- (IBAction)onboardingWorkEmailTextField:(id)sender;

- (IBAction)nextButtonTutorial:(id)sender;

@end
