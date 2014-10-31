//
//  VCCommuteSetUpOnBoardingViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuteSetUpOnBoardingViewController.h"
#import <MBProgressHUD.h>
#import "VCButtonStandardStyle.h"
#import "VCInterfaceManager.h"
#import "VCTicketViewController.h"
#import "VCUserStateManager.h"

@interface VCCommuteSetUpOnBoardingViewController ()
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *setUpCommuteButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *skipButton;
- (IBAction)didTapSetUpCommuteButton:(id)sender;
- (IBAction)didTapSkipButton:(id)sender;


@end

@implementation VCCommuteSetUpOnBoardingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    // Now that the user has entered all their profile information, load it into the app
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[VCUserStateManager instance] refreshProfileWithCompleition:^{
        [hud hide:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSetUpCommuteButton:(id)sender {
    VCTicketViewController * vc = [[VCTicketViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapSkipButton:(id)sender {
    [[VCInterfaceManager instance] showRiderInterface];
}
@end
