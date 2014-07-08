//
//  VCRideViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTripBaseViewController.h"
#import <MBProgressHUD.h>
#import "VCMapQuestRouting.h"
#import "IIViewDeckController.h"

@interface VCTripBaseViewController () <MKMapViewDelegate>

@end

@implementation VCTripBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (!self.geocoder) {
            self.geocoder = [[CLGeocoder alloc] init];
            

        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _map = [[MKMapView alloc] initWithFrame:self.view.frame];
    _map.delegate = self;
    [self.view insertSubview:_map atIndex:0];
    _map.showsUserLocation = YES;
    
}

- (void) viewDidAppear:(BOOL)animated {
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset Map" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(resetInterface)];
    self.viewDeckController.navigationItem.rightBarButtonItem = anotherButton;
    _map.userTrackingMode = MKUserTrackingModeFollow;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) annotateMeetingPoint: (CLLocation *) meetingPoint andDropOffPoint: (CLLocation *) dropOffPoint {
    
    _meetingPointAnnotation = [[MKPointAnnotation alloc] init];
    _meetingPointAnnotation.coordinate = CLLocationCoordinate2DMake(meetingPoint.coordinate.latitude, meetingPoint.coordinate.longitude);
    _meetingPointAnnotation.title = @"Pickup Location";
    _meetingPointAnnotation.subtitle = self.transport.meetingPointPlaceName;
    [_map addAnnotation:_meetingPointAnnotation];
    
    
    _dropOffAnnotation = [[MKPointAnnotation alloc] init];
    _dropOffAnnotation.coordinate = CLLocationCoordinate2DMake(dropOffPoint.coordinate.latitude, dropOffPoint.coordinate.longitude);
    _dropOffAnnotation.title = @"Drop Off Location";
    _dropOffAnnotation.subtitle = self.transport.dropOffPointPlaceName;
    [_map addAnnotation:_dropOffAnnotation];
    
}


- (void) showSuggestedRoute {
    [self showSuggestedRoute:nil to:nil];
}

- (void) showSuggestedRoute: (CLLocation *) from to: (CLLocation *) to {
    
    CLLocationCoordinate2D dropOffPointCoordinate;
    CLLocationCoordinate2D meetingPointCoordinate;
    if(from == nil) {
        dropOffPointCoordinate.latitude = [_transport.dropOffPointLatitude doubleValue];
        dropOffPointCoordinate.longitude = [_transport.dropOffPointLongitude doubleValue];
        meetingPointCoordinate.latitude = [_transport.meetingPointLatitude doubleValue];
        meetingPointCoordinate.longitude = [_transport.meetingPointLongitude doubleValue];
    } else {
        dropOffPointCoordinate.latitude = from.coordinate.latitude;
        dropOffPointCoordinate.longitude = from.coordinate.longitude;
        meetingPointCoordinate.latitude = to.coordinate.latitude;
        meetingPointCoordinate.longitude = to.coordinate.longitude;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText= @"Fetching Route";
    [VCMapQuestRouting route:meetingPointCoordinate to:dropOffPointCoordinate success:^(MKPolyline *polyline, MKCoordinateRegion region) {
        _routeOverlay = polyline;
        [_map addOverlay:_routeOverlay];
        region.span.latitudeDelta *= 1.10;
        region.span.longitudeDelta *= 1.10;
        self.rideRegion = region;
        [_map setRegion:region];
        [hud hide:YES];
    } failure:^{
        [UIAlertView showWithTitle:@"Network Error" message:@"Woops, we couldn't contact the routing server.  You can still manage your ride though!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        NSLog(@"%@", @"Error talking with MapQuest routing API");
        [hud hide:YES];
    }];
    
}

- (void) clearMap {
    [_map removeAnnotation:_meetingPointAnnotation];
    [_map removeAnnotation:_dropOffAnnotation];
    [_map removeOverlay:_routeOverlay];
}

- (void) resetInterface {
    NSAssert(0, @"Must implement this method");
}


#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer*    aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
        if([overlay isEqual:_routeOverlay]){
            aRenderer.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
            aRenderer.lineWidth = 4;
        }
        return aRenderer;
    }
    
    return nil;
}

@end
