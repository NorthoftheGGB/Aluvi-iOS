//
//  VCRideViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideViewController.h"
#import <MapKit/MapKit.h>
#import "VCLabel.h"
#import "VCButtonStandardStyle.h"


@interface VCRideViewController () <MKMapViewDelegate>

//map

@property (strong, nonatomic) MKMapView *map;


//outlets
@property (strong, nonatomic) IBOutlet UIView *homeActionView;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *editCommuteButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *rideNowButton;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *scheduleRideButton;

@property (strong, nonatomic) IBOutlet UIView *rideInfoItemView;
@property (weak, nonatomic) IBOutlet VCLabel *itemNameLabel;
@property (strong, nonatomic) IBOutlet UIView *itemValueLabel;

- (IBAction)didTapEditCommute:(id)sender;
- (IBAction)didTapRideNow:(id)sender;
- (IBAction)didTapScheduleRide:(id)sender;



@end

@implementation VCRideViewController

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
    self.title = @"Home";
    
}
- (void) viewWillAppear:(BOOL)animated{
    [self showHome];
    
    _map = [[MKMapView alloc] initWithFrame:self.view.frame];
    _map.delegate = self;
    [self.view insertSubview:_map atIndex:0];
    _map.showsUserLocation = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) showHome{
    
    CGRect frame = _homeActionView.frame;
     frame.origin.x = 0;
     frame.origin.y = self.view.frame.size.height - 53;
     _homeActionView.frame = frame;
     [self.view addSubview:self.homeActionView];
    
}

- (IBAction)didTapEditCommute:(id)sender {
}

- (IBAction)didTapRideNow:(id)sender {
}

- (IBAction)didTapScheduleRide:(id)sender {
}
@end
