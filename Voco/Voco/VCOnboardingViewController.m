//
//  VCOnboardingViewController.m
//  Voco
//
//  Created by matthewxi on 8/18/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingViewController.h"
#import "VCLogInViewController.h"
#import "VCOnboardingChildViewController.h"
#import "VCOnboardingSetRouteViewController.h"
#import "VCOnboardingUserPhotoViewController.h"
#import "VCOnboardingPersonalInfoViewController.h"
#import "Route.h"
#import "VCStyle.h"

@interface VCOnboardingViewController ()<VCOnboardingChildViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSArray * viewControllers;

@property (strong, nonatomic) Route * route;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation VCOnboardingViewController



- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    
    CGRect frame = [[[UIApplication sharedApplication] delegate] window].frame;
    CGSize size = frame.size;
    size.width = size.width * 4;
    self.scrollView.frame = self.view.frame;
    [self.scrollView setContentSize:size];
    self.scrollView.contentInset=UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    CGRect gradientFrame = frame;
    gradientFrame.size.width = size.width;
    [self.scrollView.layer insertSublayer:[VCStyle gradientLayer:gradientFrame] atIndex:0];
    [self.view setNeedsLayout];
    
    
    vc0.view.frame = frame;
    
    CGRect frame2 = frame;
    frame2.origin.x = frame.size.width;
    vc1.view.frame = frame2;
    
    CGRect frame3 = frame;
    frame3.origin.x = 2 * frame.size.width;
    vc2.view.frame = frame3;
    
    CGRect frame4 = frame;
    frame4.origin.x = 3 * frame.size.width;
    vc3.view.frame = frame4;
    
    [self.scrollView addSubview:vc0.view];
    [self.scrollView addSubview:vc1.view];
    [self.scrollView addSubview:vc2.view];
    [self.scrollView addSubview:vc3.view];
    
    _viewControllers = @[vc0,vc1,vc2,vc3];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) VCOnboardingChildViewControllerDidFinish: (VCOnboardingChildViewController*) onboardingChildViewController {
    
    CGRect visible = CGRectMake(320 * (onboardingChildViewController.index + 1), 0, 320, self.view.frame.size.height);
    [self.scrollView scrollRectToVisible:visible animated:YES];
}


@end
