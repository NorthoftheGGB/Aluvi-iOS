//
//  VCRideViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideViewController.h"
#import <MapKit/MapKit.h>
#import <ActionSheetPicker-3.0/ActionSheetStringPicker.h>
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
    //self.title = @"Home";
    //custom image
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appcoda-logo.png"]];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancel:)];
    self.navigationItem.rightBarButtonItem = cancelItem;
    
    
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

- (void) moveToEditCommute {
    [_homeActionView removeFromSuperview];
    
    CGRect frame = _rideInfoItemView.frame;
    frame.origin.x = 0;
    frame.origin.y = 62;
    frame.size.height = 0;
    _rideInfoItemView.frame = frame;
    [self.view addSubview:self.rideInfoItemView];
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _rideInfoItemView.frame;
        frame.size.height = 47;
        _rideInfoItemView.frame = frame;
    }];
    
    NSArray *morningOptions = @[
                                @"6:00", @"6:30", @"7:00", @"7:30",
                                @"8:00", @"8:30", @"9:00", @"9:30",
                                @"10:00", @"10:30", @"11:00", @"11:30",
                                @"12:00"];
    
    [ActionSheetStringPicker showPickerWithTitle: @"coco"
                                            rows: morningOptions
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self editHome];
                                       } cancelBlock:^(ActionSheetStringPicker *picker) {
                                           [self resetInterface];
                                       } origin:self.view];
}

- (void) resetInterface {
    [UIView transitionWithView:self.view duration:.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_rideInfoItemView removeFromSuperview];
        [self showHome];
    } completion:nil];

}

- (void) editHome {
    
}
    


- (void) didTapCancel: (id)sender {
    [self resetInterface];
}

- (IBAction)didTapEditCommute:(id)sender {
    [self moveToEditCommute];
    
}

- (IBAction)didTapRideNow:(id)sender {
}

- (IBAction)didTapScheduleRide:(id)sender {
}
@end
