//
//  VCRiderPaymentsViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderPaymentsViewController.h"
#import <Stripe.h>
#import <STPView.h>
#import <MBProgressHUD.h>
#import <UIAlertView+Blocks.h>
#import "VCTextField.h"
#import "VCButtonFontBold.h"
#import "VCUsersApi.h"

#define kChangeCardText @"Change Card"
#define kUpdateCardText @"Update Card"
#define kInterfaceStateDisplayCard 1
#define kInterfaceStateUpdateCard 2

@interface VCRiderPaymentsViewController () <STPViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *STPViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *recieptListTableView;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *updateCardButton;
@property (weak, nonatomic) IBOutlet UILabel *cardInfoLabel;
@property (strong, nonatomic) STPView * cardView;
@property (nonatomic) NSInteger state;

- (IBAction)didTapUpdate:(id)sender;

@end

@implementation VCRiderPaymentsViewController

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
    self.title = @"Payments";
    _updateCardButton.enabled = YES;
    _updateCardButton.titleLabel.text = kChangeCardText;
    _state = kInterfaceStateDisplayCard;
    
    // If the current user has a card display info about the card
    _cardInfoLabel.text = @"Default Card Summary";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapUpdate:(id)sender {
    
    if( _state == kInterfaceStateDisplayCard) {
        
        _state = kInterfaceStateUpdateCard;
        [_updateCardButton setTitle:kUpdateCardText forState:UIControlStateNormal];
        _updateCardButton.enabled = FALSE;
        _cardView = [[STPView alloc] initWithFrame:CGRectMake(15,20,290,55) andKey:@"pk_test_4Gt6M02YRqmpk7yoBud7y5Ah"];
        _cardView.delegate = self;
        [_STPViewContainer addSubview:_cardView];
        _cardInfoLabel.hidden = YES;
        
        
    } else {
        
        MBProgressHUD * progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHUD.labelText = @"Saving Card";
        [_cardView createToken:^(STPToken *token, NSError *error) {
            if (error == nil) {
                [VCUsersApi updateDefaultCard:[RKObjectManager sharedManager]
                                    cardToken:token.tokenId
                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                          progressHUD.hidden = YES;
                                          [UIAlertView showWithTitle:@"Card Updated" message:@"Your card has been saved" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                          _updateCardButton.titleLabel.text = @"Change Card";
                                          [_cardView removeFromSuperview];
                                          _cardView = nil;
                                          _updateCardButton.titleLabel.text = kChangeCardText;
                                          _cardInfoLabel.hidden = NO;
                                          _state = kInterfaceStateDisplayCard;

                                      }
                                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                          progressHUD.hidden = YES;
                                          [UIAlertView showWithTitle:@"Error" message:@"There was a problem saving your card.  Please try again." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                      }];
            } else {
                progressHUD.hidden = YES;
                [WRUtilities criticalError:error];
            }
        }];
        
    }
    
}

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    // Enable the "save" button only if the card form is complete.
    if(valid){
        _updateCardButton.enabled = YES;
    } else {
        _updateCardButton.enabled = NO;
        
    }
}
@end
