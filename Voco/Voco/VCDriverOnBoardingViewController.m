//
//  VCDriverOnBoardingViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverOnBoardingViewController.h"
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

#define kDriversLicenseFieldTag 1
#define kBrandFieldTag 2
#define kModelFieldtag 3
#define kYearTag 4
#define kColorTag 5
#define kLicensePlateFieldTag 6


@interface VCDriverOnBoardingViewController ()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet VCTextField *driversLicenseNumberTextField;

@property (weak, nonatomic) IBOutlet VCTextField *brandTextField;
@property (weak, nonatomic) IBOutlet VCTextField *modelTextField;
@property (weak, nonatomic) IBOutlet VCTextField *yearTextField;
@property (weak, nonatomic) IBOutlet VCTextField *colorTextField;
@property (weak, nonatomic) IBOutlet VCTextField *licensePlateTextField;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *skipThisStepButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *saveButton;


@property (weak, nonatomic) IBOutlet UIView *STPViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *cardInfoLabel;

- (IBAction)didTapSkipThisStep:(id)sender;
- (IBAction)didTapSave:(id)sender;


@end

@implementation VCDriverOnBoardingViewController

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
    self.title = @"Interested In Driving?";
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

- (IBAction)didTapSkipThisStep:(id)sender {
}

- (IBAction)didTapSave:(id)sender {
}


- (IBAction)didEndOnExit:(id)sender {
    
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kDriversLicenseFieldTag:
            [_brandTextField
             becomeFirstResponder];
            break;
            
        case kBrandFieldTag:
            [_modelTextField
             becomeFirstResponder];
            break;
            
        case kModelFieldtag:
            [_yearTextField
             becomeFirstResponder];
            break;
            
        case kYearTag:
            [_colorTextField
             becomeFirstResponder];
            break;
            
        case kColorTag:
            [_licensePlateTextField
             becomeFirstResponder];
            break;
            
        case kLicensePlateFieldTag:
            [sender resignFirstResponder];
            break;
    }
    

}

@end
