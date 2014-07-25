//
//  VCRideViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTransitBaseViewController.h"
#import <MBProgressHUD.h>
#import "VCMapQuestRouting.h"
#import "IIViewDeckController.h"

@interface VCTransitBaseViewController () <MKMapViewDelegate>

@end

@implementation VCTransitBaseViewController

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
    _meetingPointAnnotation.subtitle = self.transit.meetingPointPlaceName;
    [_map addAnnotation:_meetingPointAnnotation];
    
    
    _dropOffAnnotation = [[MKPointAnnotation alloc] init];
    _dropOffAnnotation.coordinate = CLLocationCoordinate2DMake(dropOffPoint.coordinate.latitude, dropOffPoint.coordinate.longitude);
    _dropOffAnnotation.title = @"Drop Off Location";
    _dropOffAnnotation.subtitle = self.transit.dropOffPointPlaceName;
    [_map addAnnotation:_dropOffAnnotation];
    
}


- (void) showSuggestedRoute {
    [self showSuggestedRoute:nil to:nil];
}

- (void) showSuggestedRoute: (CLLocation *) from to: (CLLocation *) to {
    
    CLLocationCoordinate2D dropOffPointCoordinate;
    CLLocationCoordinate2D meetingPointCoordinate;
    dropOffPointCoordinate.latitude = from.coordinate.latitude;
    dropOffPointCoordinate.longitude = from.coordinate.longitude;
    meetingPointCoordinate.latitude = to.coordinate.latitude;
    meetingPointCoordinate.longitude = to.coordinate.longitude;
    
    //MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText= @"Fetching Route";
    [VCMapQuestRouting route:meetingPointCoordinate to:dropOffPointCoordinate success:^(MKPolyline *polyline, MKCoordinateRegion region) {
        [_map removeOverlay:_routeOverlay];
        _routeOverlay = polyline;
        [_map addOverlay:_routeOverlay];
        region.span.latitudeDelta *= 1.5;
        region.span.longitudeDelta *= 1.5;
        //region.center.latitude *= .98;
        
        // TODO: need to adjust region
        self.rideRegion = region;
        [_map setRegion:region];
        //[hud hide:YES];
    } failure:^{
        // [UIAlertView showWithTitle:@"Network Error" message:@"Woops, we couldn't contact the routing server.  You can still manage your ride though!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        NSLog(@"%@", @"Error talking with MapQuest routing API");
        //[hud hide:YES];
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


// IBOutlets
- (IBAction)didTapCurrentLocationButton:(id)sender {
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = self.map.userLocation.coordinate.latitude;
    mapRegion.center.longitude = self.map.userLocation.coordinate.longitude;
    mapRegion.span.latitudeDelta = self.map.region.span.latitudeDelta;
    mapRegion.span.longitudeDelta = self.map.region.span.longitudeDelta;
    [self.map setRegion:mapRegion animated: YES];
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
