//
//  VCCenterViewBaseViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCenterViewBaseViewController.h"
#import "IIViewDeckController.h"

@interface VCCenterViewBaseViewController ()

@property (nonatomic) BOOL toggle;
@end

@implementation VCCenterViewBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _toggle = YES;
        _showHamburger = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(_showHamburger){
        [self showHamburgerBarButton];
    }
}

- (void) showHamburgerBarButton {
    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapHamburger)];
    self.navigationItem.leftBarButtonItem = hamburgerButton;
    self.navigationItem.leftBarButtonItem.tintColor= [UIColor colorWithRed:(162/255.f) green:(148/255.f) blue:(144/255.f) alpha:1.0];
    
}

- (void) didTapHamburger {
    
    if(_toggle==YES) {
        [self.navigationController.viewDeckController openLeftView];
        _toggle = NO;
    }
    else {
        [self.navigationController.viewDeckController closeLeftView];
        _toggle = YES;
    }
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
