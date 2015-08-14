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

@interface VCPaymentsViewController () <PTKViewDelegate>

@property (strong, nonatomic) PTKView * cardView;
@property (weak, nonatomic) IBOutlet UIView *PTKViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *commuterAccountBalance;

@end

@implementation VCPaymentsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    _cardView = [[PTKView alloc] initWithFrame:CGRectMake(15,20,290,55)];
    _cardView.delegate = self;
    
    [_PTKViewContainer addSubview:_cardView];
    
    [self updateFieldValues];

    [[VCUserStateManager instance] refreshProfileWithCompletion:^{
        [self updateFieldValues];
    }];
}

- (void) updateFieldValues {
    _commuterAccountBalance.text = [NSString stringWithFormat:@"$%.2f", [[VCUserStateManager instance].profile.commuterBalanceCents doubleValue] / 100];

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
                                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                      [self somethingDidntGoRight];
                                      [WRUtilities criticalError:error];
                                      
                                  }];
        } else {
            [WRUtilities subcriticalErrorWithString:@"Something didn't go right.  Want to try that again?"];
            [WRUtilities criticalError:error];
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

@end
