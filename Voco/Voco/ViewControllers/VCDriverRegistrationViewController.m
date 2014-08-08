//
//  VCDriverCreateAccountCreditCardViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverRegistrationViewController.h"
#import <M13Checkbox.h>
#import "VCTextField.h"
#import "VCDriverApi.h"
#import "VCDriverVideoTutorialController.h"
#import <MBProgressHUD.h>
#import "VCBankAccountTextField.h"
#import "VCRoutingNumberTextField.h"
#import "VCCarBrandTextField.h"
#import "VCCarModelTextField.h"
#import "VCCarYearTextField.h"
#import "VCCarLicensePlateTextField.h"
#import "VCDriversLicenseTextField.h"
#import "VCReferralCodeTextField.h"

#define kDriversLicenseFieldTag 1
#define kReferralCodeFieldTag 2
#define kAccountNameFieldTag 3
#define kAccountNumberFieldTag 4
#define kRoutingNumberFieldTag 5
#define kBrandFieldTag 6
#define kModelFieldtag 7
#define kYearTag 8
#define kLicensePlateFieldTag 9

@interface VCDriverRegistrationViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *accountNameField;
@property (weak, nonatomic) IBOutlet VCTextField *accountNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *routingNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *brandField;
@property (weak, nonatomic) IBOutlet VCTextField *modelField;
@property (weak, nonatomic) IBOutlet VCTextField *yearField;
@property (weak, nonatomic) IBOutlet VCTextField *licensePlateField;
@property (weak, nonatomic) IBOutlet UIView *checkboxOutlet;
@property (weak, nonatomic) IBOutlet VCTextField *driversLicenseField;
@property (weak, nonatomic) IBOutlet UITextField *referralCodeField;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) M13Checkbox * termsCheckbox;

- (IBAction)didTapTermsOfService:(id)sender;
- (IBAction)didTapContinue:(id)sender;

@end

@implementation VCDriverRegistrationViewController

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
    self.title = @"Driver Registration";
    
    [self.scrollView setContentSize:_contentView.frame.size];
    [self.scrollView addSubview:_contentView];
#if DEBUG==1
    _accountNumberField.text = @"000123456789";
    _routingNumberField.text = @"110000000";
#endif
    
    _termsCheckbox = [[M13Checkbox alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _termsCheckbox.strokeColor = [UIColor blackColor];
    _termsCheckbox.checkColor = [UIColor redColor];
    [_checkboxOutlet addSubview:_termsCheckbox];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerDriver{
    
    
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Registering...";

    
 [VCDriverApi registerDriverWithLicenseNumber:_driversLicenseField.text
                              bankAccountName:_accountNameField.text
                            bankAccountNumber:_accountNumberField.text
                           bankAccountRouting:_routingNumberField.text
                                     carBrand:_brandField.text
                                     carModel:_modelField.text
                                      carYear:_yearField.text
                              carLicensePlate:_licensePlateField.text
                                 referralCode:_referralCodeField.text
                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                          [hud hide:YES];
                                          VCDriverVideoTutorialController * vc = [[VCDriverVideoTutorialController alloc] init];
                                          NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
                                          [viewControllers removeLastObject];
                                          [viewControllers addObject:vc];
                                          [[self navigationController] setViewControllers:viewControllers animated:YES];
                                          
                                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                          [hud hide:YES];
                                      }];
    
}

#pragma mark IBActions

- (IBAction)didTapTermsOfService:(id)sender {
}

- (IBAction)didTapAgree:(id)sender {
}

- (IBAction)didTapContinue:(id)sender {
    // Validate
    
    [self registerDriver];
}

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kDriversLicenseFieldTag:
            [_referralCodeField becomeFirstResponder];
            break;
            
        case kReferralCodeFieldTag:
            [_accountNameField
             becomeFirstResponder];
            break;
            
        case kAccountNameFieldTag:
            [_accountNumberField becomeFirstResponder];
            break;
            
        case kAccountNumberFieldTag:
            [_routingNumberField
             becomeFirstResponder];
            break;
            
        case kRoutingNumberFieldTag:
            [_brandField
             becomeFirstResponder];
            break;
            
        case kBrandFieldTag:
            [_modelField
             becomeFirstResponder];
            break;
        
        case kModelFieldtag:
            [_yearField
             becomeFirstResponder];
            break;
            
        case kYearTag:
            [_licensePlateField
             becomeFirstResponder];
            break;
            
        case kLicensePlateFieldTag:
            [sender resignFirstResponder];
            break;
    }
    
}

@end
