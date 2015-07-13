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
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset Map"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(resetInterface)];
    self.viewDeckController.navigationItem.rightBarButtonItem = anotherButton;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
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
 */


- (void) showSuggestedRoute {
    [self showSuggestedRoute:nil to:nil];
}

- (void) showSuggestedRoute: (CLLocation *) from to: (CLLocation *) to {
    
    _map.userTrackingMode = MKUserTrackingModeNone;

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
        if(region.span.latitudeDelta == 0 || region.span.longitudeDelta == 0){
            return;
        }
        
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

- (void) clearRoute {
    [_map removeOverlay:_routeOverlay];
}

- (void) clearMap {
    [self clearRoute];
}

- (void) resetInterface {
    NSAssert(0, @"Must implement this method");
}

- (void) zoomToCurrentLocation {
    if(self.map.userLocation != nil
       && self.map.userLocation.coordinate.latitude != 0
       && self.map.userLocation.coordinate.longitude != 0) {
        
        [self.map setRegion:MKCoordinateRegionMakeWithDistance(
                                                               CLLocationCoordinate2DMake(self.map.userLocation.location.coordinate.latitude, self.map.userLocation.coordinate.longitude),
                                                               500, 500
                                                               )
                                                               animated: YES];
    }
}


// IBOutlets
- (IBAction)didTapCurrentLocationButton:(id)sender {
    [self zoomToCurrentLocation];
}



#pragma mark MKMapViewDelegate
/* No longer used ?? */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer*    aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
        if([overlay isEqual:_routeOverlay]){
            aRenderer.strokeColor = [UIColor colorWithRed:17.0f / 256.0f green: 119.0f / 256.0f blue: 45.0f / 256.0f alpha:.7];
            aRenderer.lineWidth = 4;
        }
        return aRenderer;
    }
    
    return nil;
}

@end
