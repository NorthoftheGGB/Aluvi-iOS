//
//  VCCommuterPassViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuterPassViewController.h"
#import "VCLabel.h"
#import "VCTextField.h"
#import "VCButtonFontBold.h"


@interface VCCommuterPassViewController ()
@property (weak, nonatomic) IBOutlet VCLabel *accountBalanceLabel;
@property (weak, nonatomic) IBOutlet VCLabel *creditCardNumberLabel;
@property (weak, nonatomic) IBOutlet VCLabel *expDateLabel;
@property (weak, nonatomic) IBOutlet VCTextField *refillAmountField;
- (IBAction)autoRefillSwitch:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *amountSegementedControl;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *didTapAddFundsButton;



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
    self.title = @"Commuter Pass";}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)autoRefillSwitch:(id)sender {
}
@end
