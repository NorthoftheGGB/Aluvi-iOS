//
//  VCProfileViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCProfileViewController.h"
#import "VCTextField.h"
#import "VCButtonStandardStyle.h"

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
    [self.scrollView addSubview:_contentView];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSaveChanges:(id)sender {
}

- (IBAction)didTapLogoutButton:(id)sender {
}

- (IBAction)didTapTakePhotoButton:(id)sender {
}
@end
