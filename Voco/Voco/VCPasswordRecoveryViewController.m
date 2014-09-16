//
//  VCPasswordRecoveryViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCPasswordRecoveryViewController.h"
#import "VCLabel.h"
#import "VCButtonStandardStyle.h"
#import "VCTextField.h"


@interface VCPasswordRecoveryViewController ()
@property (weak, nonatomic) IBOutlet VCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *sendPasswordButton;
- (IBAction)didTapSendPasswordButton:(id)sender;

@end

@implementation VCPasswordRecoveryViewController

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
    self.title = @"Password Recovery";}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSendPasswordButton:(id)sender {
}
@end
