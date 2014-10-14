//
//  VCRiderOnBoardingViewController.h
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCScrollableFormViewController.h"

@interface VCRiderOnBoardingViewController : VCScrollableFormViewController

@property (strong, nonatomic) NSAttributedString * termsOfServiceString;
@property (strong, nonatomic) NSString * desiredEmail;
@property (strong, nonatomic) NSString * desiredPassword;

@end
