//
//  VCDriverChangeBankAccountViewController.h
//  Voco
//
//  Created by Elliott De Aratanha on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCBankAccountTextField.h"
#import "VCRoutingNumberTextField.h"
#import "VCTextField.h"
#import "VCTextField.h"
#import "VCLabel.h"
#import "VCLabelBold.h"
#import "VCButtonFontBold.h"

@interface VCDriverChangeBankAccountViewController : UIViewController
@property (weak, nonatomic) IBOutlet VCTextField *accountNameTextField;
@property (weak, nonatomic) IBOutlet VCBankAccountTextField *accountNumberTextField;
@property (weak, nonatomic) IBOutlet VCRoutingNumberTextField *routingNumberTextField;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *sumbitButton;
- (IBAction)didTapSubmit:(id)sender;

@end
