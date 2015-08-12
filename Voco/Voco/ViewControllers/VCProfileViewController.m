//
//  VCProfileViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCProfileViewController.h"
#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <PKImagePickerViewController.h>
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
#import "UIImage+Resize.h"
#import "VCApi.h"
#import "VCStyle.h"
#import "VCNotifications.h"

@interface VCProfileViewController () <PKImagePickerViewControllerDelegate, UINavigationControllerDelegate>

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
@property (strong, nonatomic) IBOutlet VCTextField *workEmailTextField;

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
- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self setGradient];
    
    VCProfile * profile = [VCUserStateManager instance].profile;
    
    _firstNameTextField.text = profile.firstName;
    _lastNameTextField.text = profile.lastName;
    _emailTextField.text = profile.email;
    _phoneTextField.text = profile.phone;
    _passwordTextField.text = @"********";
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:profile.largeImageUrl]
                   placeholderImage:[UIImage imageNamed:@"placeholder-profile.png"]];
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    _versionLabel.text = [NSString stringWithFormat:@"v%@b%@", version, build];
    
}

- (void) didTapHamburger {
    [self dismissKeyboard:self];
    [super didTapHamburger];
}

- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) done:(id)sender{
    [((UITextField *) sender) resignFirstResponder];
}

- (IBAction)didTapSaveChanges:(id)sender {

    BOOL notify = NO;
    if(![[VCUserStateManager instance].profile.firstName isEqualToString:_firstNameTextField.text]
       || ![[VCUserStateManager instance].profile.lastName isEqualToString:_lastNameTextField.text] ){
        notify = YES;
    }
    
    [VCUserStateManager instance].profile.firstName = _firstNameTextField.text;
    [VCUserStateManager instance].profile.lastName = _lastNameTextField.text;
    [VCUserStateManager instance].profile.email = _emailTextField.text;
    [VCUserStateManager instance].profile.phone = _phoneTextField.text;
    [VCUserStateManager instance].profile.workEmail = _workEmailTextField.text;
    [[VCUserStateManager instance] saveProfile];
    
    if(notify){
        [VCNotifications profileUpdated];
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCUsersApi updateProfile:[VCUserStateManager instance].profile
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          [hud hide:YES];
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          [hud hide:YES];
                      }];
}

- (IBAction)didTapLogoutButton:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated: YES];
    [[VCUserStateManager instance] logoutWithCompletion:^{
        [hud hide:YES];
        [[VCInterfaceManager instance] showRiderSigninInterface];
    }];
}

- (IBAction)didTapTakePhotoButton:(id)sender {
    
    PKImagePickerViewController *imagePicker = [[PKImagePickerViewController alloc]init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    /*
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:^{
        [hud hide:YES];
    }];
    */
}

#pragma mark - PKImagePickerControllerDelegate

-(void)imageSelected:(UIImage*)img {
    CGSize size = CGSizeMake(640, 750);
    UIImage * image = [img resizedImageToFitInSize:size scaleIfSmaller:YES];
    _userImageView.image = image;
    
    NSMutableURLRequest *request =
    [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                             method:RKRequestMethodPOST
                                                               path:API_USER_PROFILE
                                                         parameters:nil
                                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                              [formData appendPartWithFileData:UIImageJPEGRepresentation(image, .9)
                                                                          name:@"image"
                                                                      fileName:@"image.jpg"
                                                                      mimeType:@"image/jpg"];
                                          }];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager]
                                           objectRequestOperationWithRequest:request
                                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                               [hud hide:YES];
                                               
                                           } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                               [UIAlertView showWithTitle:@"Problem" message:@"There was a problem saving your image" cancelButtonTitle:@"Darn." otherButtonTitles:nil tapBlock:nil];
                                               [hud hide:YES];
                                               
                                           }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
    

}

-(void)imageSelectionCancelled {
    
}



@end
