//
//  VCPasswordRecoveryViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCPasswordRecoveryViewController.h"
#import <MBProgressHUD.h>
#import "VCLabel.h"
#import "VCButtonBold.h"
#import "VCTextField.h"
#import "VCUsersApi.h"
#import "VCStyle.h"


@interface VCPasswordRecoveryViewController ()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet VCTextField *emailTextField;
@property (weak, nonatomic) IBOutlet VCButtonBold *sendPasswordButton;
- (IBAction)didTapSendPasswordButton:(id)sender;

@end

@implementation VCPasswordRecoveryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.showHamburger = NO;
    }
    return self;
}

- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.view.layer insertSublayer:gradient atIndex:0];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setGradient];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _contentView.frame = self.scrollView.frame;
    //   [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.scrollView setContentSize:_contentView.frame.size];
    [self.scrollView addSubview:_contentView];
    
}




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void) didTapBack {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSendPasswordButton:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCUsersApi forgotPassword:[RKObjectManager sharedManager]
                         email:_emailTextField.text
                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                           [hud hide:YES];
                           [UIAlertView showWithTitle:@"Success"
                                              message:@"Please check your email for your new password"
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil tapBlock:nil];
                       }
                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                           [hud hide:YES];
                           [UIAlertView showWithTitle:@"Failure"
                                              message:@"We were not able to reset your password.  Please try again or contact support"
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil tapBlock:nil];
                       }];
}
@end
