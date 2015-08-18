//
//  VCOnboardingUserPhotoViewController.h
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCOnboardingChildViewController.h"

@interface VCOnboardingUserPhotoViewController : VCOnboardingChildViewController
@property (strong, nonatomic) IBOutlet UIImageView *onboardingUserImage;



- (IBAction)onboardingTakePhoto:(id)sender;
- (IBAction)onboardingChooseExistingPhoto:(id)sender;
- (IBAction)nextButtonPersonalInfo:(id)sender;

@end
