//
//  PasswordRecoveryViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/5/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "PasswordRecoveryViewController.h"
#import "VCTextField.h"

#define kPhoneFieldTag 1
#define kEmailFieldTag 2

@interface PasswordRecoveryViewController ()

@property (strong, nonatomic) IBOutlet VCTextField *phoneField;
@property (weak, nonatomic) IBOutlet VCTextField *emailField;
- (IBAction)didTapSendPassword:(id)sender;


@end

@implementation PasswordRecoveryViewController

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

- (IBAction)didTapSendPassword:(id)sender {
    [self recoverEmail];
    
}

- (IBAction)didEndOnExit:(id)sender {
    
    UITextField * textField = (UITextField *) sender;
    switch(textField.tag){
        case kPhoneFieldTag:
            [_emailField becomeFirstResponder];
            break;
        case kEmailFieldTag:
            [self recoverEmail];
            break;
    }
}

- (void) recoverEmail{
// Validation & server stuff
    
}


@end
