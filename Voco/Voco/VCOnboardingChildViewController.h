//
//  VCOnboardingChildViewController.h
//  Voco
//
//  Created by matthewxi on 8/18/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EmailValueKey @"EmailValueKey"
#define PasswordValueKey @"PasswordValueKey"
#define RouteObjectValueKey @"RouteObjectValueKey"
#define ProfileImageValueKey @"ProfileImageValueKey"
#define FirstNameValueKey @"FirstNameValueKey"
#define LastNameValueKey @"LastNameValueKey"
#define PhoneNumberValueKey @"PhoneNumberValueKey"
#define WorkEmailValueKey @"WorkEmailValueKey"
#define DriverValueKey @"DriverValueKey"


@class VCOnboardingChildViewController;

@protocol VCOnboardingChildViewControllerDelegate <NSObject>

- (void) VCOnboardingChildViewControllerDidFinish: (VCOnboardingChildViewController*) onboardingChildViewController;
- (void) VCOnboardingChildViewController: (VCOnboardingChildViewController *) onboardingChildViewController didSetValues:(NSDictionary *) values;
@end

@interface VCOnboardingChildViewController : UIViewController

@property (weak, nonatomic) id<VCOnboardingChildViewControllerDelegate> delegate;
@property (assign, nonatomic) NSInteger index;

@end
