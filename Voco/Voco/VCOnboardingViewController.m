//
//  VCOnboardingViewController.m
//  Voco
//
//  Created by matthewxi on 8/18/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingViewController.h"
#import <MBProgressHUD.h>
#import "VCUserStateManager.h"
#import "VCInterfaceManager.h"
#import "VCLogInViewController.h"
#import "VCOnboardingChildViewController.h"
#import "VCOnboardingSetRouteViewController.h"
#import "VCOnboardingUserPhotoViewController.h"
#import "VCOnboardingPersonalInfoViewController.h"
#import "VCCommuteManager.h"
#import "Route.h"
#import "VCStyle.h"
#import "VCUsersApi.h"
#import "VCNotifications.h"
#import "UIImage+DeviceSpecificMedia.h"

#define kTutorialSize 4


@interface VCOnboardingViewController ()<VCOnboardingChildViewControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSArray * viewControllers;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableDictionary * values;

@property (nonatomic) BOOL locked;
@property (nonatomic) NSInteger currentIndex;
@end

@implementation VCOnboardingViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _values = [NSMutableDictionary dictionary];
    _locked = YES;
    _currentIndex = 0;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_currentIndex == 0) {
    VCLogInViewController * vc0 = [[VCLogInViewController alloc] init];
    vc0.index = 0;
    vc0.delegate = self;
    VCOnboardingChildViewController * vc1 = [[VCOnboardingSetRouteViewController alloc] init];
    vc1.index = 1;
    vc1.delegate = self;;
    VCOnboardingChildViewController * vc2 = [[VCOnboardingUserPhotoViewController alloc] init];
    vc2.index = 2;
    vc2.delegate = self;;
    VCOnboardingChildViewController * vc3 = [[VCOnboardingPersonalInfoViewController alloc] init];
    vc3.index = 3;
    vc3.delegate = self;
    
    [self addChildViewController:vc1];
    [self addChildViewController:vc2];
    [self addChildViewController:vc3];
    
    CGRect frame = [[[UIApplication sharedApplication] delegate] window].frame;
    CGSize size = frame.size;
    size.width = size.width * (kTutorialSize+4);
    self.scrollView.frame = self.view.frame;
    [self.scrollView setContentSize:size];
    self.scrollView.contentInset=UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.delegate = self;
    
    CGRect gradientFrame = frame;
    gradientFrame.size.width = size.width;
    [self.scrollView.layer insertSublayer:[VCStyle gradient2Layer:gradientFrame] atIndex:0];
    [self.view setNeedsLayout];
    
    CGRect frame1 = frame;
    frame1.origin.x = kTutorialSize * frame.size.width;
    vc0.view.frame = frame1;
    
    CGRect frame2 = frame;
    frame2.origin.x = (kTutorialSize+1) * frame.size.width;
    vc1.view.frame = frame2;
    
    CGRect frame3 = frame;
    frame3.origin.x = (kTutorialSize+2) * frame.size.width;
    vc2.view.frame = frame3;
    
    CGRect frame4 = frame;
    frame4.origin.x = (kTutorialSize+3) * frame.size.width;
    vc3.view.frame = frame4;
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageForDeviceWithName:@"tutorial"]];
    CGRect imageViewFrame = frame;
    imageViewFrame.size.width = frame.size.width * kTutorialSize;
    imageView.frame = imageViewFrame;
    [self.scrollView addSubview:imageView];
    [self.scrollView addSubview:vc0.view];
    [self.scrollView addSubview:vc1.view];
    [self.scrollView addSubview:vc2.view];
    [self.scrollView addSubview:vc3.view];
    
    _viewControllers = @[vc0,vc1,vc2,vc3];
    
    self.navigationController.navigationBarHidden = YES;
    
    _currentIndex = kTutorialSize;
    if([[NSUserDefaults standardUserDefaults] boolForKey:kSkipTutorial]){
        [self.scrollView setContentOffset:CGPointMake(kTutorialSize * frame.size.width, 0) animated:NO];
    } else {
    }
        
    }

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) VCOnboardingChildViewController:(VCOnboardingChildViewController *)onboardingChildViewController
                            didSetValues:(NSDictionary *)values {
    [_values setValuesForKeysWithDictionary:values];
}

- (void) VCOnboardingChildViewControllerDidFinish: (VCOnboardingChildViewController*) onboardingChildViewController {
    
    if(onboardingChildViewController.index + 1 == [_viewControllers count]){
        [self registerUser];
    } else {
        NSInteger width = [[[UIApplication sharedApplication] delegate] window].frame.size.width;
        CGRect visible = CGRectMake(width * (onboardingChildViewController.index + 1 + kTutorialSize), 0, width, self.view.frame.size.height);
        _currentIndex = onboardingChildViewController.index + 1 + kTutorialSize;
        _locked = NO;
        _scrollView.userInteractionEnabled = NO;
        [self.scrollView scrollRectToVisible:visible animated:YES];
    }
}

- (void)VCOnboardingChildViewController:(VCOnboardingChildViewController *)onboardingChildViewController
               didRequestPushController:(UIViewController *)viewController {
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_locked) {
        NSInteger width = [[[UIApplication sharedApplication] delegate] window].frame.size.width;
        if (scrollView.contentOffset.x > _currentIndex * width ) {
            [scrollView setContentOffset:CGPointMake(_currentIndex * width, 0)];
        }
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _locked = YES;
    _scrollView.userInteractionEnabled = YES;
}

- (void) registerUser {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[VCUserStateManager instance] createUser:[RKObjectManager sharedManager]
                                    firstName:[_values objectForKey:FirstNameValueKey]
                                     lastName:[_values objectForKey:LastNameValueKey]
                                        email:[_values objectForKey:EmailValueKey]
                                     password:[_values objectForKey:PasswordValueKey]
                                        phone:[_values objectForKey:PhoneNumberValueKey]
                                 referralCode:nil
                                       driver:[_values objectForKey:DriverValueKey]
                                      success:^() {
                                          
                                          hud.hidden = YES;
                                          
                                          [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSkipTutorial];
                                          [[NSUserDefaults standardUserDefaults] synchronize];
                                          
                                          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                              
                                              
                                              // User created!  we can send in the route in the background
                                              [[VCCommuteManager instance] storeCommuterSettings:[_values objectForKey:RouteObjectValueKey ]  success:^{
                                                  
                                              } failure:^(NSString *errorMessage) {
                                                  [UIAlertView showWithTitle:@"Whoops" message:errorMessage cancelButtonTitle:@"Hmm" otherButtonTitles:nil tapBlock:nil];
                                              }];
                                              
                                              // Also attempt to send profile image in background
                                              
                                              [[VCUserStateManager instance] refreshProfileWithCompletion:^{
                                                  
                                                  [VCUsersApi updateProfileImage:[_values objectForKey:ProfileImageValueKey] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                      
                                                      [VCUserStateManager instance].profile.workEmail = [_values objectForKey:WorkEmailValueKey];
                                                      [[VCUserStateManager instance] saveProfileWithCompletion:^{
                                                          //
                                                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                          //
                                                      }];
                                                      
                                                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                      //
                                                  }];

                                              }];
                                              
                                          });
                                          
                                          
                                          [[VCInterfaceManager instance] showRiderInterface];
                                          
                                          
                                      } failure:^(NSString * errorString) {
                                          hud.hidden = YES;
                                          
                                          [UIAlertView showWithTitle:@"Problem" message:errorString cancelButtonTitle:@"Ok I will" otherButtonTitles:nil tapBlock:nil];
                                      }];
    
}

@end
