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
}

-(void)imageSelectionCancelled {
    
}


@end
