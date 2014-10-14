//
//  VCCommuteSetUpOnBoardingViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/24/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuteSetUpOnBoardingViewController.h"
#import "VCButtonStandardStyle.h"
#import "VCInterfaceManager.h"
#import "VCTicketViewController.h"


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
    // Do any additional setup after loading the view from its nib.
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
