//
//  VCRideViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideViewController.h"
#import <MapKit/MapKit.h>
#import "VCMapQuestRouting.h"

@interface VCRideViewController () <MKMapViewDelegate>

// Map
@property (strong, nonatomic) MKMapView * map;
@property (strong, nonatomic) MKPolyline * routeOverlay;
@property (strong, nonatomic) CLGeocoder * geocoder;

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
    
    _map = [[MKMapView alloc] initWithFrame:self.view.frame];
    _map.delegate = self;
    _map.showsUserLocation = YES;
    _map.userTrackingMode = YES;
    [self.view insertSubview:_map atIndex:0];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showRideLocations {
    
    MKPointAnnotation *pickupAnnotation = [[MKPointAnnotation alloc] init];
    pickupAnnotation.coordinate = CLLocationCoordinate2DMake([self.ride.meetingPointLatitude doubleValue], [self.ride.meetingPointLongitude doubleValue]);
    pickupAnnotation.title = @"Pickup Location";
    pickupAnnotation.subtitle = self.ride.meetingPointPlaceName;
    [_map addAnnotation:pickupAnnotation];
    
    
    MKPointAnnotation *dropOffAnnotation = [[MKPointAnnotation alloc] init];
    dropOffAnnotation.coordinate = CLLocationCoordinate2DMake([self.ride.destinationLatitude doubleValue], [self.ride.destinationLongitude doubleValue]);
    dropOffAnnotation.title = @"Drop Off Location";
    dropOffAnnotation.subtitle = self.ride.destinationPlaceName;
    [_map addAnnotation:dropOffAnnotation];

}

- (void) showSuggestedRoute {
    
    //TODO: create confirmation step and UI
    CLLocationCoordinate2D destinationCoordinate;
    CLLocationCoordinate2D departureCoordinate;
    destinationCoordinate.latitude = [_ride.destinationLatitude doubleValue];
    destinationCoordinate.longitude = [_ride.destinationLongitude doubleValue];
    departureCoordinate.latitude = [_ride.originLatitude doubleValue];
    departureCoordinate.longitude = [_ride.originLongitude doubleValue];
    
    [VCMapQuestRouting route:destinationCoordinate to:departureCoordinate region:_map.region success:^(MKPolyline *polyline) {
        _routeOverlay = polyline;
        [_map addOverlay:_routeOverlay];
    } failure:^{
        NSLog(@"%@", @"Error talking with MapQuest routing API");
    }];
    
}

@end
