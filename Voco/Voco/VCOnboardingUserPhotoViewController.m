//
//  VCOnboardingUserPhotoViewController.m
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingUserPhotoViewController.h"
#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <PKImagePickerViewController.h>
#import "UIImage+Resize.h"


@interface VCOnboardingUserPhotoViewController ()<PKImagePickerViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *onboardingUserImage;
@property (strong, nonatomic) UIImage * profileImage;

- (IBAction)onboardingTakePhoto:(id)sender;
- (IBAction)onboardingChooseExistingPhoto:(id)sender;
- (IBAction)nextButtonPersonalInfo:(id)sender;

@end


@implementation VCOnboardingUserPhotoViewController

- (void) viewDidLoad {
    
#ifdef SPOOF
    UIImage * img = [UIImage imageNamed:@"logo_in"];
    CGSize size = CGSizeMake(640, 750);
    _profileImage = [img resizedImageToFitInSize:size scaleIfSmaller:YES];
    _onboardingUserImage.image = _profileImage;
    _onboardingUserImage.layer.cornerRadius = _onboardingUserImage.frame.size.width / 2;
    _onboardingUserImage.clipsToBounds = YES;
#endif
}

- (IBAction)onboardingTakePhoto:(id)sender {
    PKImagePickerViewController *imagePicker = [[PKImagePickerViewController alloc]init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)onboardingChooseExistingPhoto:(id)sender {
}

- (IBAction)nextButtonPersonalInfo:(id)sender {
    if(_profileImage == nil){
        [UIAlertView showWithTitle:@"Please select a user image" message:@"Ridesharing isn't anonymous.  We require a user image to help facilitate trust and safety between our users" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
         return;
    }
    NSDictionary * values = @{
                              ProfileImageValueKey : _profileImage
                              };
    [self.delegate VCOnboardingChildViewController:self didSetValues:values];
    [self.delegate VCOnboardingChildViewControllerDidFinish:self];

}


#pragma mark - PKImagePickerControllerDelegate

-(void)imageSelected:(UIImage*)img {
    CGSize size = CGSizeMake(640, 750);
    _profileImage = [img resizedImageToFitInSize:size scaleIfSmaller:YES];
    _onboardingUserImage.image = _profileImage;
    _onboardingUserImage.layer.cornerRadius = _onboardingUserImage.frame.size.width / 2;
    _onboardingUserImage.clipsToBounds = YES;
}

-(void)imageSelectionCancelled {
    
}

-(void)imageSelectionError:(NSError*)error {
    NSString * errorMessage = [NSString stringWithFormat:@"Please make sure the camera is enabled.  %@", [error debugDescription]];
    [UIAlertView showWithTitle:@"Image Capture Error" message:errorMessage cancelButtonTitle:   @"OK" otherButtonTitles:nil tapBlock:nil];
}


@end
