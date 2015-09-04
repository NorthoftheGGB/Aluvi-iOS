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
#import "VCStyle.h"

@interface VCPaymentsViewController () <PTKViewDelegate>

@property (strong, nonatomic) PTKView * cardView;
@property (weak, nonatomic) IBOutlet UIView *PTKViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *commuterAccountBalance;
@property (weak, nonatomic) IBOutlet UIButton *processPayoutButton;
@property (strong, nonatomic) IBOutlet UILabel *payWithCardLabel;
@property (strong, nonatomic) IBOutlet UILabel *getPaidToCardLabel;
@property (strong, nonatomic) IBOutlet UILabel *paymentsDescriptionLabel;


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
    _cardView.delegate = self;
    
    [_PTKViewContainer addSubview:_cardView];
    
    [self updateFieldValues];

    [[VCUserStateManager instance] refreshProfileWithCompletion:^{
        [self updateFieldValues];
    }];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelCardEntry)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithCardEntry)],
                           nil];
    [numberToolbar sizeToFit];
    _cardView.cardNumberField.inputAccessoryView = numberToolbar;
    _cardView.cardExpiryField.inputAccessoryView = numberToolbar;
    _cardView.cardCVCField.inputAccessoryView = numberToolbar;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_delegate != nil){
        [_cardView becomeFirstResponder];
    }
}

- (void) cancelCardEntry {
    [_cardView resignFirstResponder];
    if(_delegate != nil && [_delegate respondsToSelector:@selector(VCPaymentsViewControllerDidCancel:)]){
        [_delegate VCPaymentsViewControllerDidCancel:self];
    }
}

- (void) doneWithCardEntry {
    [_cardView resignFirstResponder];
    [self didTapSave:nil];
}





- (void) updateFieldValues {
    _commuterAccountBalance.text = [NSString stringWithFormat:@"$%.2f", [[VCUserStateManager instance].profile.commuterBalanceCents doubleValue] / 100];
    
    if( [[VCUserStateManager instance] isHovDriver]){
        _processPayoutButton.hidden = NO;
        if ([[VCUserStateManager instance].profile.commuterBalanceCents intValue] > 1000){
            _processPayoutButton.enabled = YES;
        }
    } else {
        _processPayoutButton.hidden = YES;
    }
    
}


- (IBAction)didTapSave:(id)sender {
    
    
    STPCard *card = [[STPCard alloc] init];
    card.number = _cardView.card.number;
    card.expMonth = _cardView.card.expMonth;
    card.expYear = _cardView.card.expYear;
    card.cvc = _cardView.card.cvc;
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving user info";
 
 
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error == nil ) {
            [VCUsersApi updateDefaultCard:[RKObjectManager sharedManager]
                                cardToken:token.tokenId
                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                      [hud hide:YES];
                                      if(_delegate != nil){
                                          [_delegate VCPaymentsViewControllerDidUpdatePaymentMethod:self];
                                      }
                                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                      [self somethingDidntGoRight];
                                      [WRUtilities criticalError:error];
                                      [hud hide:YES];
                                      
                                  }];
        } else {
            [WRUtilities subcriticalErrorWithString:[error.userInfo objectForKey:@"com.stripe.lib:ErrorMessageKey"]];
            [hud hide:YES];

        }
    }];
}

- (void) somethingDidntGoRight {
    [UIAlertView showWithTitle:@"Woops" message:@"Something didn't go right. Want to try that again?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yeah"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex == 1){
            [self didTapSave:self];
        }
    }];
}

- (IBAction)didTapProcessPayoutButton:(id)sender {
    if([VCUserStateManager instance].profile.recipientCardLastFour == nil) {
        [self getPayoutCard];
    } else {
        [self requestPayout];
    }
}


- (void) getPayoutCard {
    
}

- (void) requestPayout {
    
}



@end
