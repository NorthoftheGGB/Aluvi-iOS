//
//  VCDriverOnBoardingViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverOnBoardingViewController.h"
#import <Stripe.h>
#import <PTKView.h>
#import <MBProgressHUD.h>
#import <UIAlertView+Blocks.h>
#import "VCTextField.h"
#import "VCButtonStandardStyle.h"
#import "VCUsersApi.h"
#import "VCRiderApi.h"
#import "Payment.h"
#import "VCUtilities.h"
#import "VCValidation.h"
#import "VCDriverApi.h"
#import "VCCommuteSetUpOnBoardingViewController.h"
#import <PTKTextField.h>

#define kDriversLicenseFieldTag 1
#define kBrandFieldTag 2
#define kModelFieldtag 3
#define kYearTag 4
#define kColorTag 5
#define kLicensePlateFieldTag 6


@interface VCDriverOnBoardingViewController () <PTKViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet VCTextField *driversLicenseNumberTextField;
@property (weak, nonatomic) IBOutlet VCTextField *brandTextField;
@property (weak, nonatomic) IBOutlet VCTextField *modelTextField;
@property (weak, nonatomic) IBOutlet VCTextField *yearTextField;
@property (weak, nonatomic) IBOutlet VCTextField *colorTextField;
@property (weak, nonatomic) IBOutlet VCTextField *licensePlateTextField;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *skipThisStepButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *saveButton;


@property (weak, nonatomic) IBOutlet UIView *PTKViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *cardInfoLabel;
@property (strong, nonatomic) PTKView * cardView;
@property (strong, nonatomic) MBProgressHUD * hud;

@property (nonatomic) BOOL stripeOK;

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
    
    self.navigationController.navigationBarHidden = YES;

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) debug:(id)sender {
    _driversLicenseNumberTextField.text = @"S02038290392";
    _brandTextField.text = @"Ford";
    _modelTextField.text = @"Prefect";
    _yearTextField.text = @"2010";
    _colorTextField.text = @"Orange";
    _licensePlateTextField.text = @"SDF234";
    _cardView.cardNumberField.text = @"4000056655665556";
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

- (void) showNextStep {
    VCCommuteSetUpOnBoardingViewController * vc = [[VCCommuteSetUpOnBoardingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapSkipThisStep:(id)sender {
    [self showNextStep];
}

- (IBAction)didTapSave:(id)sender {
    if(![_brandTextField validate]){
        return;
    }
    if(![_modelTextField validate]){
        return;
    }
    if(![_yearTextField validate]){
        return;
    }
    if(![_colorTextField validate]){
        return;
    }
    if(![_licensePlateTextField validate]){
        return;
    }
    if(![_driversLicenseNumberTextField validate]){
        return;
    }
    
    if(_stripeOK == NO){
        [UIAlertView showWithTitle:@"Error"
                           message:@"You must enter a valid debit card to recieve payouts"
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil tapBlock:nil];
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
        
        if(error == nil) {
            [VCDriverApi registerDriverWithLicenseNumber:_driversLicenseNumberTextField.text
                                                carBrand:_brandTextField.text
                                                carModel:_modelTextField.text
                                                 carYear:_yearTextField.text
                                         carLicensePlate:_licensePlateTextField.text
                                            referralCode:@""
                                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                     [VCUsersApi updateRecipientCard:[RKObjectManager sharedManager]
                                                                           cardToken:token.tokenId
                                                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                 [self showNextStep];
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
            [WRUtilities criticalError:error];
        }
    }];
    
}

- (void) somethingDidNotGoRight {
    _hud.hidden = YES;
    [WRUtilities subcriticalErrorWithString:@"Something didn't go right.  Want to try that again?"];
    
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



- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    // Enable the "save" button only if the card form is complete.
    if(valid){
        _stripeOK = YES;
    } else {
        _stripeOK = NO;
    }
    
}

- (void)paymentViewDidStartEditing:(PTKView *)paymentView {
    self.scrollFocusView = _PTKViewContainer;
}

@end
