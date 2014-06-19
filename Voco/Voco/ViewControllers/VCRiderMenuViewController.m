//
//  VCRiderMenuViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/11/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderMenuViewController.h"

@interface VCRiderMenuViewController ()

//rider menu

- (IBAction)didTapUserMode:(id)sender;
- (IBAction)didTapProfile:(id)sender;
- (IBAction)didTapPaymentInfo:(id)sender;
- (IBAction)didTapScheduledRide:(id)sender;
- (IBAction)didTapCummuterPass:(id)sender;
- (IBAction)didTapAboutUs:(id)sender;
- (IBAction)didTapTermsAndConditions:(id)sender;
- (IBAction)didTapSupport:(id)sender;
- (IBAction)didTapTutorial:(id)sender;

//driver menu
- (IBAction)didTapDriverProfile:(id)sender;
- (IBAction)didTapDriverPaymentInfo:(id)sender;
- (IBAction)didTapDriverScheduledFares:(id)sender;
- (IBAction)didTapDriverMyCar:(id)sender;
- (IBAction)didTapDriverAboutUs:(id)sender;
- (IBAction)didTapDriverTermsAndConditions:(id)sender;
- (IBAction)didTapDriverSupport:(id)sender;
- (IBAction)didTapDriverTutorial:(id)sender;



@end

@implementation VCRiderMenuViewController

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
//rider actions

- (IBAction)didTapUserMode:(id)sender {
}

- (IBAction)didTapProfile:(id)sender {
}

- (IBAction)didTapPaymentInfo:(id)sender {
}

- (IBAction)didTapScheduledRide:(id)sender {
}

- (IBAction)didTapCummuterPass:(id)sender {
}

- (IBAction)didTapAboutUs:(id)sender {
}

- (IBAction)didTapTermsAndConditions:(id)sender {
}

- (IBAction)didTapSupport:(id)sender {
}

- (IBAction)didTapTutorial:(id)sender {
}

//driver outlets



- (IBAction)didTapDriverProfile:(id)sender {
}

- (IBAction)didTapDriverPaymentInfo:(id)sender {
}

- (IBAction)didTapDriverScheduledFares:(id)sender {
}

- (IBAction)didTapDriverMyCar:(id)sender {
}

- (IBAction)didTapDriverAboutUs:(id)sender {
}

- (IBAction)didTapDriverTermsAndConditions:(id)sender {
}

- (IBAction)didTapDriverSupport:(id)sender {
}

- (IBAction)didTapDriverTutorial:(id)sender {
}
@end
