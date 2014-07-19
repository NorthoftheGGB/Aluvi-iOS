//
//  VCRiderProfileViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/15/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderProfileViewController.h"
#import <MBProgressHUD.h>
#import "VCNameTextField.h"
#import "VCEmailTextField.h"
#import "VCPasswordTextField.h"
#import "VCTextField.h"
#import "VCButtonFontBold.h"
#import "VCLabelBold.h"
#import "VCLabel.h"
#import "VCUserState.h"
#import "VCInterfaceModes.h"
#import "VCUsersApi.h"

@interface VCRiderProfileViewController ()

@property (weak, nonatomic) IBOutlet VCNameTextField *firstNameField;
@property (weak, nonatomic) IBOutlet VCNameTextField *lastNameField;
@property (weak, nonatomic) IBOutlet VCPasswordTextField *passwordField;
@property (weak, nonatomic) IBOutlet VCEmailTextField *emailField;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *changeButton;

@property (weak, nonatomic) IBOutlet VCLabel *referralCodeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *socialSegmentedControl;

@property (weak, nonatomic) IBOutlet UIView *newsCheckBoxView;
@property (weak, nonatomic) IBOutlet UIView *promoCheckBoxView;
@property (weak, nonatomic) IBOutlet UIView *receiptsCheckBoxView;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *signoutButton;


- (IBAction)didTapChangeButton:(id)sender;
- (IBAction)didTapSocialSegmentedControl:(id)sender;
- (IBAction)didTapSignoutButton:(id)sender;

@end

@implementation VCRiderProfileViewController

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
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCUsersApi getProfile:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        hud.hidden = YES;
        VCProfile * profile = mappingResult.firstObject;
        _firstNameField.text = profile.firstName;
        _lastNameField.text = profile.lastName;
        _passwordField.text = @"********";
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        hud.hidden = YES;
        
    }];
    
    
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

- (IBAction)didTapChangeButton:(id)sender {
}

- (IBAction)didTapSocialSegmentedControl:(id)sender {
}

- (IBAction)didTapSignoutButton:(id)sender {
    [[VCUserState instance] logout];
    [[VCInterfaceModes instance] showRiderSigninInterface];

}
@end
