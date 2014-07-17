//
//  VCDriverPaymentsViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/15/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverPaymentsViewController.h"
#import "VCBankAccountTextField.h"
#import "VCRoutingNumberTextField.h"
#import "VCTextField.h"
#import "VCTextField.h"
#import "VCLabel.h"
#import "VCLabelBold.h"
#import "VCButtonFontBold.h"


@interface VCDriverPaymentsViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *accountNameTextField;
@property (weak, nonatomic) IBOutlet VCBankAccountTextField *accountNumberTextField;
@property (weak, nonatomic) IBOutlet VCRoutingNumberTextField *routingNumberTextField;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *changeBankInfoButton;
@property (weak, nonatomic) IBOutlet UITableView *receiptsTableViewCell;


- (IBAction)didTapChangeBankInfo:(id)sender;


@end

@implementation VCDriverPaymentsViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapChangeBankInfo:(id)sender {
}
@end
