//
//  VCDriverHomeViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverHomeViewController.h"
#import "VCLabel.h"

@interface VCDriverHomeViewController ()
- (IBAction)didTapAccept:(id)sender;
- (IBAction)didTapDecline:(id)sender;
- (IBAction)didTapRiderPickedUp:(id)sender;
- (IBAction)didTapCancelRide:(id)sender;

//Driver Location HUD

@property (strong, nonatomic) IBOutlet UIView *driverLocationHud;

- (IBAction)didTapZoomRideBounds:(id)sender;
- (IBAction)didTapCurrentLocation:(id)sender;

@property (weak, nonatomic) IBOutlet VCLabel *pickupLocationLabel;
@property (weak, nonatomic) IBOutlet VCLabel *addressLabel;



@end

@implementation VCDriverHomeViewController

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

- (IBAction)didTapAccept:(id)sender {
}

- (IBAction)didTapDecline:(id)sender {
}

- (IBAction)didTapRiderPickedUp:(id)sender {
}

- (IBAction)didTapCancelRide:(id)sender {
}
- (IBAction)didTapeRideCompleted:(id)sender {
}
- (IBAction)didTapZoomRideBounds:(id)sender {
}

- (IBAction)didTapCurrentLocation:(id)sender {
}
@end
