//
//  VCOnboardingViewController.m
//  Voco
//
//  Created by matthewxi on 8/18/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingViewController.h"
#import "VCOnboardingChildViewController.h"

@interface VCOnboardingViewController () <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;


@end

@implementation VCOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
     
    return nil;
}


@end
