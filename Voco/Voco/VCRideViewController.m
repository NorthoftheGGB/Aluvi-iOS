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
#import <ActionSheetCustomPicker.h>
#import "VCLabel.h"
#import "VCButtonStandardStyle.h"
#import "VCEditLocationWidget.h"

@interface VCRideViewController () <MKMapViewDelegate, VCEditLocationWidgetDelegate>

// map
@property (strong, nonatomic) MKMapView *map;
@property (strong, nonatomic) MKPointAnnotation * originAnnotation;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;

// outlets
@property (strong, nonatomic) IBOutlet UIView *homeActionView;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *editCommuteButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *rideNowButton;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *scheduleRideButton;

@property (strong, nonatomic) IBOutlet UIView *rideInfoItemView;
@property (weak, nonatomic) IBOutlet VCLabel *itemNameLabel;
@property (strong, nonatomic) IBOutlet UIView *itemValueLabel;

@property (strong, nonatomic) VCEditLocationWidget * homeLocationWidget;
@property (strong, nonatomic) VCEditLocationWidget * workLocationWidget;

@property (nonatomic) BOOL appeared;

- (IBAction)didTapEditCommute:(id)sender;
- (IBAction)didTapRideNow:(id)sender;
- (IBAction)didTapScheduleRide:(id)sender;
- (IBAction)didTapCurrentLocation:(id)sender;



@end

@implementation VCRideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _appeared = NO;
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
    
    _homeLocationWidget = [[VCEditLocationWidget alloc] init];
    _homeLocationWidget.delegate = self;
    _workLocationWidget = [[VCEditLocationWidget alloc] init];
    _workLocationWidget.delegate = self;
    _homeLocationWidget.type = kHomeType;
    _workLocationWidget.type = kWorkType;
    [self addChildViewController:_homeLocationWidget];
    [self addChildViewController:_workLocationWidget];

    
}
- (void) viewWillAppear:(BOOL)animated{
    
    if(!_appeared){
        [self showHome];
    
        _map = [[MKMapView alloc] initWithFrame:self.view.frame];
        _map.delegate = self;
        [self.view insertSubview:_map atIndex:0];
        _map.showsUserLocation = YES;
        
        _appeared = YES;
    }
    
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
    
   // [ActionSheetCustomPicker showPickerWithTitle:@"Departure Time" delegate:self showCancelButton:YES origin:self.view];
}

- (void) resetInterface {
    [UIView transitionWithView:self.view duration:.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_rideInfoItemView removeFromSuperview];
        [_homeLocationWidget.view removeFromSuperview];
        [_workLocationWidget.view removeFromSuperview];
        [self showHome];
    } completion:nil];

}

- (void) editHome {
    _homeLocationWidget.mode = kEditLocationWidgetEditMode;
    CGRect frame = _homeLocationWidget.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 109;
    frame.size.height = 0;
    _homeLocationWidget.view.frame = frame;
    [self.view addSubview:_homeLocationWidget.view];

    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _homeLocationWidget.view.frame;
        frame.size.height = 47;
        _homeLocationWidget.view.frame = frame;
    }];

    
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

- (IBAction)didTapCurrentLocation:(id)sender {
}


#pragma mark - VCLocationSearchViewControllerDelegate
- (void) editLocationWidget:(VCEditLocationWidget *)widget didSelectMapItem:(MKMapItem *)mapItem {
    if(_originAnnotation != nil){
        [_map removeAnnotation:_originAnnotation];
    }
    _originAnnotation = [[MKPointAnnotation alloc] init];
    _originAnnotation.coordinate = CLLocationCoordinate2DMake(mapItem.placemark.coordinate.latitude, mapItem.placemark.coordinate.longitude);
    _originAnnotation.title = @"Home";
    [_map addAnnotation:_originAnnotation];
    [_map setCenterCoordinate:mapItem.placemark.coordinate animated:YES];
}

@end
