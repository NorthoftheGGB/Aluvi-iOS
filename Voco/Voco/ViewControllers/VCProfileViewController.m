//
//  VCProfileViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCProfileViewController.h"
#import <MBProgressHUD.h>
#import "VCNameTextField.h"
#import "VCEmailTextField.h"
#import "VCPasswordTextField.h"
#import "VCPhoneTextField.h"
#import "VCTextField.h"
#import "VCButtonStandardStyle.h"
#import "VCLabel.h"
#import "VCUserStateManager.h"
#import "VCInterfaceManager.h"
#import "VCUsersApi.h"


@interface VCProfileViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

//User Image + Controls
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;

//Text Fields
@property (weak, nonatomic) IBOutlet VCTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet VCTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet VCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet VCTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet VCTextField *passwordTextField;

//Version
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

//Buttons
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *saveChangesButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *logoutButton;

- (IBAction)didTapSaveChanges:(id)sender;

- (IBAction)didTapLogoutButton:(id)sender;

- (IBAction)didTapTakePhotoButton:(id)sender;

@end

@implementation VCProfileViewController

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
    [self.scrollView setContentSize:_contentView.frame.size];
    [self.scrollView addSubview:_contentView];
    
    VCProfile * profile = [VCUserStateManager instance].profile;
    _firstNameTextField.text = profile.firstName;
    _lastNameTextField.text = profile.lastName;
    _emailTextField.text = profile.email;
    //TODO: phone field
    _passwordTextField.text = @"********";

UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
[tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];

NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
_versionLabel.text = [NSString stringWithFormat:@"v%@b%@", version, build];

}

- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)didTapSaveChanges:(id)sender {
    //TODO: API fun fun
}

- (IBAction)didTapLogoutButton:(id)sender {
    [[VCUserStateManager instance] logout];
    [[VCInterfaceManager instance] showRiderSigninInterface];
}

- (IBAction)didTapTakePhotoButton:(id)sender {
    //TODO: take a picture
}
@end
