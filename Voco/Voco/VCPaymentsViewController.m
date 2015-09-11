//
//  VCPaymentsView.m
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCPaymentsViewController.h"
#import <Stripe.h>
#import <PTKView.h>
#import <PTKTextField.h>
#import <MBProgressHUD.h>
#import "VCUserStateManager.h"
#import "VCUsersApi.h"
#import "VCRidesApi.h"
#import "VCUserStateManager.h"
#import "Receipt.h"
#import "VCStyle.h"
#import "NSDate+Pretty.h"
#import "VCLabelSmall.h"

#define kCardView 1001
#define kDebitCardView 1002

@interface VCPaymentsViewController () <PTKViewDelegate>

@property (strong, nonatomic) PTKView * cardView;
@property (strong, nonatomic) PTKView * debitCardView;

@property (weak, nonatomic) IBOutlet UIView *PTKViewContainer;
@property (weak, nonatomic) IBOutlet UIView *PTKDebitViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *commuterAccountBalance;
@property (weak, nonatomic) IBOutlet UIButton *processPayoutButton;
@property (weak, nonatomic) IBOutlet UILabel *defaultCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *getPaidToCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentsDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet VCLabelSmall *lastTransactionLabel;

@end

@implementation VCPaymentsViewController

- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.view.layer insertSublayer:gradient atIndex:0];
}


- (void) viewDidLoad {
    [super viewDidLoad];
    [self setGradient];
    
    _cardView = [[PTKView alloc] initWithFrame:CGRectMake(15,20,290,55)];
    _cardView.tag = kCardView;
    _cardView.delegate = self;
    [_PTKViewContainer addSubview:_cardView];
    
    _debitCardView = [[PTKView alloc] initWithFrame:CGRectMake(15,20,290,55)];
    _debitCardView.tag = kDebitCardView;
    _debitCardView.delegate = self;
    [_PTKDebitViewContainer addSubview:_debitCardView];


    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.tintColor = [VCStyle greenColor];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain  target:self action:@selector(cancelCardEntry)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneWithCardEntry)],
                           nil];
    [numberToolbar sizeToFit];
    _cardView.cardNumberField.inputAccessoryView = numberToolbar;
    _cardView.cardExpiryField.inputAccessoryView = numberToolbar;
    _cardView.cardCVCField.inputAccessoryView = numberToolbar;
    _debitCardView.cardNumberField.inputAccessoryView = numberToolbar;
    _debitCardView.cardExpiryField.inputAccessoryView = numberToolbar;
    _debitCardView.cardCVCField.inputAccessoryView = numberToolbar;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_delegate != nil){
        [_cardView becomeFirstResponder];
    }
    
    [self updateFieldValues];
    
    [[VCUserStateManager instance] refreshProfileWithCompletion:^{
        [self updateFieldValues];
    }];
    
    [self updateLastTransaction];
    [VCRidesApi refreshReceiptsWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self updateLastTransaction];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
    }];

}

- (void) cancelCardEntry {
    if([_cardView isFirstResponder]){
        [_cardView resignFirstResponder];
    } else if([_debitCardView isFirstResponder]){
        [_debitCardView resignFirstResponder];
    }
    if(_delegate != nil && [_delegate respondsToSelector:@selector(VCPaymentsViewControllerDidCancel:)]){
        [_delegate VCPaymentsViewControllerDidCancel:self];
    }
}

- (void) doneWithCardEntry {
    if([_cardView isFirstResponder]){
        [_cardView resignFirstResponder];
        [self didTapSave:_cardView];
    } else if([_debitCardView isFirstResponder]){
        [_debitCardView resignFirstResponder];
        [self didTapSave:_debitCardView];
    }
}





- (void) updateFieldValues {
    VCProfile * profile = [VCUserStateManager instance].profile;
    double accountBalance = [profile.commuterBalanceCents integerValue];
    if(accountBalance > 0) {
        _commuterAccountBalance.text = [NSString stringWithFormat:@"You've Collected $%.2f", accountBalance / 100.0f];
    } else if (accountBalance < 0) {
        _commuterAccountBalance.text = [NSString stringWithFormat:@"You've Spent $%.2f", -accountBalance/ 100.0f];
    } else {
        _commuterAccountBalance.text = @"No Balance";
    }
        


    
    if(profile.cardLastFour == nil && profile.recipientCardLastFour == nil){
        _defaultCardLabel.text = @"No Payment Method Entered";
    }
    
    _getPaidToCardLabel.hidden = YES;
    _debitCardView.hidden = YES;
    if(profile.cardLastFour != nil){
        NSString * text = [NSString stringWithFormat:@"%@ ending in %@", profile.cardBrand, profile.cardLastFour ];
        if( profile.recipientCardLastFour != nil
           && [profile.recipientCardLastFour isEqualToString:profile.cardLastFour]
           && [profile.recipientCardBrand isEqualToString:profile.cardBrand]
           ){
            _defaultCardLabel.text = text;
        } else {
            _defaultCardLabel.text = [NSString stringWithFormat:@"Pay with %@", text];
            if(profile.recipientCardLastFour != nil){
                _getPaidToCardLabel.hidden = NO;
                _getPaidToCardLabel.text = [NSString stringWithFormat:@"Get paid to %@ ending in  %@", profile.recipientCardBrand, profile.recipientCardLastFour];
                _debitCardView.hidden = NO;
            }
        }
    }
    
    if (accountBalance > 1000){
        _processPayoutButton.hidden = NO;
        _processPayoutButton.enabled = YES;
        _paymentsDescriptionLabel.hidden = NO;
        if(profile.recipientCardLastFour == nil){
            _getPaidToCardLabel.hidden = NO;
            _getPaidToCardLabel.text = @"No Debit Card Entered";
            _debitCardView.hidden = NO;
        }
    } else {
        _processPayoutButton.hidden = YES;
        _processPayoutButton.enabled = NO;
        _paymentsDescriptionLabel.hidden = YES;
    }
    
    
}

- (void) updateLastTransaction {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Receipt"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"type = 'payment' OR type = 'payout'"];
    [request setPredicate:predicate];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSSortDescriptor * sort2 = [NSSortDescriptor sortDescriptorWithKey:@"receiptId" ascending:YES];
    [request setSortDescriptors:@[sort, sort2]];

    NSError *error;
    NSArray * receipts = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
    if(receipts == nil){
        [WRUtilities criticalError:error];
    }
    if([receipts count] > 0){
    Receipt * lastTransaction = receipts[0];
        if([lastTransaction.type isEqualToString:@"payment"]){
            _lastTransactionLabel.text = [NSString stringWithFormat:@"Last Charged $%.2f on %@", [lastTransaction.amount doubleValue], [lastTransaction.date typicalDate]
                                              ];
        } else {
            _lastTransactionLabel.text = [NSString stringWithFormat:@"Last Deposited $%.2f on %@", -[lastTransaction.amount doubleValue],
                                              [lastTransaction.date typicalDate]];
        }
        _lastTransactionLabel.hidden = NO;
    } else {
        _lastTransactionLabel.hidden = YES;
    }
}


- (IBAction)didTapSave:(id)sender {
    
    PTKView * selectedCardView = sender;
    
    STPCard *card = [[STPCard alloc] init];
    card.number = selectedCardView.card.number;
    card.expMonth = selectedCardView.card.expMonth;
    card.expYear = selectedCardView.card.expYear;
    card.cvc = selectedCardView.card.cvc;
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving user info";
 
 
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error == nil ) {
            
            if(selectedCardView.tag == kCardView){
                
                [[VCUserStateManager instance] updateDefaultCard:token.tokenId
                                                         success:^{
                                                             [hud hide:YES];
                                                             if(_delegate != nil){
                                                                 [_delegate VCPaymentsViewControllerDidUpdatePaymentMethod:self];
                                                             }
                                                             [self updateFieldValues];
                                                             
                                                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                             [self somethingDidntGoRight:selectedCardView];
                                                             [WRUtilities criticalError:error];
                                                             [hud hide:YES];
                                                         }];
                
            } else if(selectedCardView.tag == kDebitCardView){
                
                [[VCUserStateManager instance] updateDefaultCard:token.tokenId
                                                         success:^{
                                                             [hud hide:YES];
                                                             if(_delegate != nil){
                                                                 [_delegate VCPaymentsViewControllerDidUpdatePaymentMethod:self];
                                                             }
                                                             [self updateFieldValues];
                                                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                             [self somethingDidntGoRight:selectedCardView];
                                                             [WRUtilities criticalError:error];
                                                             [hud hide:YES];
                                                         }];
            }
        } else {
            [WRUtilities subcriticalErrorWithString:[error.userInfo objectForKey:@"com.stripe.lib:ErrorMessageKey"]];
            [hud hide:YES];

        }
    }];
}

- (void) somethingDidntGoRight:(PTKView *) selectedCardView {
    [UIAlertView showWithTitle:@"Whoops" message:@"Something didn't go right. Want to try that again?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yeah"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex == 1){
            [self didTapSave:selectedCardView];
        }
    }];
}

- (IBAction)didTapProcessPayoutButton:(id)sender {
    [self processPayout];
}

- (void) processPayout {
    if([VCUserStateManager instance].profile.recipientCardLastFour == nil) {
        [self getPayoutCard];
    } else {
        [self requestPayout];
    }
}

- (void) getPayoutCard {
    [UIAlertView showWithTitle:@"We need a debit card" message:@"We need a debit card to withdraw fund to" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [_debitCardView becomeFirstResponder];
    }];
}

- (void) requestPayout {
    NSString * message = [NSString stringWithFormat:@"$%.2f will be deposited into your %@ debit card ending in %@",
                          [[VCUserStateManager instance].profile.commuterBalanceCents intValue] / 100.0f,
    [VCUserStateManager instance].profile.cardBrand,
                          [VCUserStateManager instance].profile.cardLastFour
                          ];
    [UIAlertView showWithTitle:@"Withdraw Funds" message:message cancelButtonTitle:@"Not Now" otherButtonTitles:@[@"OK, Do it!"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 1:
            {
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"Requesting Withdrawal";
                [VCUsersApi payoutRequestedWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    hud.hidden = YES;
                    [UIAlertView showWithTitle:@"Success" message:@"Your withdrawal will be processed shortly.  You will receive a push message once funds are transfered" cancelButtonTitle:@"Ok Great!" otherButtonTitles:nil tapBlock:nil];
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    hud.hidden = YES;
                    [UIAlertView showWithTitle:@"Sorry" message:@"We ran into a problem.  Want to try that again?" cancelButtonTitle:@"Not Now"otherButtonTitles:@[@"Yes try again please"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if(buttonIndex == 1){
                            [self processPayout];
                        }
                    }];
                }];
            }
                break;
                
            default:
                break;
        }
    }];
}

- (IBAction)didTapCancel:(id)sender {
    [self cancelCardEntry];
}

@end
