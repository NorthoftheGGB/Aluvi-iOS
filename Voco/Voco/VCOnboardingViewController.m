//
//  VCOnboardingViewController.m
//  Voco
//
//  Created by matthewxi on 8/18/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingViewController.h"
#import "VCOnboardingChildViewController.h"
#import "VCOnboardingSetRouteViewController.h"
#import "VCOnboardingUserPhotoViewController.h"
#import "VCOnboardingPersonalInfoViewController.h"
#import "Route.h"

@interface VCOnboardingViewController () <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSArray * viewControllers;

@property (strong, nonatomic) Route * route;

@end

@implementation VCOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    VCOnboardingChildViewController * vc1 = [[VCOnboardingSetRouteViewController alloc] init];
    vc1.index = 0;
    VCOnboardingChildViewController * vc2 = [[VCOnboardingUserPhotoViewController alloc] init];
    vc2.index = 1;
    VCOnboardingChildViewController * vc3 = [[VCOnboardingPersonalInfoViewController alloc] init];
    vc3.index = 2;
    _viewControllers = @[vc1,vc2,vc3];
    
    [_pageController setViewControllers:@[_viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:_pageController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(VCOnboardingChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(VCOnboardingChildViewController *)viewController index];
    
    
    index++;
    
    if (index == 5) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}


- (VCOnboardingChildViewController *)viewControllerAtIndex:(NSUInteger)index {
   
    /*
    APPChildViewController *childViewController = [[APPChildViewController alloc] initWithNibName:@"APPChildViewController" bundle:nil];
    childViewController.index = index;
    
    return childViewController;
    */
     
  //  return nil;
//}


@end
