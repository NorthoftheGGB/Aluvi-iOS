//
//  DriverRequestViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "DriverRequestViewController.h"
#import "VCTextField.h"


#define kNameFieldTag 1
#define kPhoneFieldTag 2
#define kEmailFieldTag 3
#define kReferralCodeFieldTag 4

@interface DriverRequestViewController ()

@property (weak, nonatomic) IBOutlet VCTextField *nameField;
@property (weak, nonatomic) IBOutlet VCTextField *phoneField;
@property (weak, nonatomic) IBOutlet VCTextField *emailField;
@property (weak, nonatomic) IBOutlet VCTextField *referralCodeField;

- (IBAction)didTapSubmit:(id)sender;


@end

@implementation DriverRequestViewController

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
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
}

- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSubmit:(id)sender {
    [self driverRequest];
}

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kNameFieldTag:
            [_phoneField becomeFirstResponder];
            break;
        case kPhoneFieldTag:
            [_emailField becomeFirstResponder];
            break;
        case kEmailFieldTag:
            [_referralCodeField becomeFirstResponder];
            break;
        case kReferralCodeFieldTag:
            [self driverRequest];
            break;
    }
}


- (void) driverRequest {
    
}
@end
