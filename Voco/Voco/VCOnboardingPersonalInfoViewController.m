//
//  VCOnboardingPersonalInfoViewController.m
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingPersonalInfoViewController.h"

@interface VCOnboardingPersonalInfoViewController ()

@end

@implementation VCOnboardingPersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)nextButtonTutorial:(id)sender {
    // validation
    [self.delegate VCOnboardingChildViewControllerDidFinish:self];
}
@end
