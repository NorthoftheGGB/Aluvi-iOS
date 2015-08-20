//
//  VCCommuterPassViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuterPassViewController.h"
#import <MBProgressHUD.h>
#import "VCLabel.h"
#import "VCTextField.h"
#import "VCButtonBold.h"
#import "VCUsersApi.h"
#import "VCUtilities.h"


@interface VCCommuterPassViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet VCLabel *accountBalanceLabel;
@property (weak, nonatomic) IBOutlet VCLabel *creditCardNumberLabel;
@property (weak, nonatomic) IBOutlet VCLabel *expDateLabel;
@property (weak, nonatomic) IBOutlet VCTextField *refillAmountField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *amountSegementedControl;
@property (weak, nonatomic) IBOutlet UISwitch *autoRefillSwitch;

- (IBAction)autoRefillSwitch:(id)sender;
- (IBAction)didTapAddFundsButton:(id)sender;
- (IBAction)didTouchRefillAmountField:(id)sender;

@end

@implementation VCCommuterPassViewController

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
    self.title = @"Commuter Pass";
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCUsersApi getProfile:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        hud.hidden = YES;
        VCProfile * profile = mappingResult.firstObject;
        if(profile.cardLastFour != nil && profile.cardBrand != nil){
            _creditCardNumberLabel.text = [NSString stringWithFormat:@"%@ XXXX-XXXX-XXXX-%@", profile.cardBrand, profile.cardLastFour];
        } else {
            _creditCardNumberLabel.text = @"No Credit Card Assigned";
        }
        if(profile.commuterBalanceCents != nil){
            _accountBalanceLabel.text = [VCUtilities formatCurrencyFromCents: profile.commuterBalanceCents];
        }
        if(profile.commuterRefillAmountCents){
            _refillAmountField.text = [VCUtilities formatCurrencyFromCents: profile.commuterRefillAmountCents];
        }
        if(profile.commuterRefillEnabled != nil){
            _autoRefillSwitch.on = [profile.commuterRefillEnabled boolValue];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        hud.hidden = YES;
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)autoRefillSwitch:(id)sender {
    VCProfile * profile = [[VCProfile alloc] init];
    BOOL selected = _autoRefillSwitch.on;
    profile.commuterRefillEnabled = [NSNumber numberWithBool: selected];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCUsersApi updateProfile:profile
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          hud.hidden = YES;
                          
                      }
                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          hud.hidden = YES;
                          
                      }];
}

- (IBAction)didTapAddFundsButton:(id)sender {
    NSInteger selectedSegment = _amountSegementedControl.selectedSegmentIndex;
    NSNumber * amount;
    switch (selectedSegment) {
        case 0:
            amount = [NSNumber numberWithInt:2000];
            break;
        case 1:
            amount = [NSNumber numberWithInt:4000];
            break;
        case 2:
            amount = [NSNumber numberWithInt:6000];
            break;
        case 3:
            amount = [NSNumber numberWithInt:8000];
            break;
        default:
            return;
            break;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCUsersApi fillCommuterPass:amount
                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             hud.hidden = YES;
                            [UIAlertView showWithTitle:@"Funds Added"
                                               message:[NSString stringWithFormat:@"%@ has been added to your commuter card",
                                                        [VCUtilities formatCurrencyFromCents:amount]]
                                     cancelButtonTitle:@"Thanks!" otherButtonTitles:nil tapBlock:nil];
                             VCProfile * profile = mappingResult.firstObject;
                             _accountBalanceLabel.text = [VCUtilities formatCurrencyFromCents:profile.commuterBalanceCents];
                             
                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                             hud.hidden = YES;

                         }];
    
}

- (IBAction)didTouchRefillAmountField:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update Refill Amoiunt?" message:@"Please enter the amount you would like to autofill" delegate:self cancelButtonTitle:@"No thanks!" otherButtonTitles:@"Update refill amount", nil];
    alert.tag = 4;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* tf = [alert textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeNumberPad;
    [alert show];

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 4 && buttonIndex == 1) {
        VCProfile * profile = [[VCProfile alloc] init];
        NSString * amountString = [alertView textFieldAtIndex:0].text;
        profile.commuterRefillAmountCents = [NSNumber numberWithFloat: [amountString doubleValue] * 100 ];
        
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [VCUsersApi updateProfile:profile
                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                              VCProfile * response = mappingResult.firstObject;
                              _accountBalanceLabel.text = [VCUtilities formatCurrencyFromCents: response.commuterBalanceCents];
                              _refillAmountField.text = [VCUtilities formatCurrencyFromCents:profile.commuterRefillAmountCents];
                              hud.hidden = YES;
                          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                              hud.hidden = YES;
                          }];
    }
}
@end
