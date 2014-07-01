//
//  VCRideViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideViewController.h"
#import "VCMapQuestRouting.h"

@interface VCRideViewController () <MKMapViewDelegate>

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
    
    _pickupAnnotation = [[MKPointAnnotation alloc] init];
    _pickupAnnotation.coordinate = CLLocationCoordinate2DMake([self.transport.meetingPointLatitude doubleValue], [self.transport.meetingPointLongitude doubleValue]);
    _pickupAnnotation.title = @"Pickup Location";
    _pickupAnnotation.subtitle = self.transport.meetingPointPlaceName;
    [_map addAnnotation:_pickupAnnotation];
    
    
    _dropOffAnnotation = [[MKPointAnnotation alloc] init];
    _dropOffAnnotation.coordinate = CLLocationCoordinate2DMake([self.transport.destinationLatitude doubleValue], [self.transport.destinationLongitude doubleValue]);
    _dropOffAnnotation.title = @"Drop Off Location";
    _dropOffAnnotation.subtitle = self.transport.destinationPlaceName;
    [_map addAnnotation:_dropOffAnnotation];
    
}

- (void) showSuggestedRoute {
    
    //TODO: create confirmation step and UI
    CLLocationCoordinate2D destinationCoordinate;
    CLLocationCoordinate2D departureCoordinate;
    destinationCoordinate.latitude = [_transport.destinationLatitude doubleValue];
    destinationCoordinate.longitude = [_transport.destinationLongitude doubleValue];
    if(_transport.meetingPointLatitude == nil || _transport.meetingPointLongitude == nil){
        // If we don't have a meeting point yet, show the route from the origin
        if([_transport isKindOfClass:[Ride class]]){
            departureCoordinate.latitude = [((Ride*) _transport).originLatitude doubleValue];
            departureCoordinate.longitude = [((Ride*) _transport).originLongitude doubleValue];
        } else {
            NSLog(@"%@", @"Inconsistent State");
            return;
        }
    } else {
        departureCoordinate.latitude = [_transport.meetingPointLatitude doubleValue];
        departureCoordinate.longitude = [_transport.meetingPointLongitude doubleValue];
    }
    
    [VCMapQuestRouting route:destinationCoordinate to:departureCoordinate region:_map.region success:^(MKPolyline *polyline, MKCoordinateRegion region) {
        _routeOverlay = polyline;
        [_map addOverlay:_routeOverlay];
        region.span.latitudeDelta *= 1.10;
        region.span.longitudeDelta *= 1.10;
        [_map setRegion:region];
    } failure:^{
        NSLog(@"%@", @"Error talking with MapQuest routing API");
    }];
    
    
    if([_transport isKindOfClass:[Ride class]]){
        Ride * ride = (Ride *) _transport;
        if(ride.originLatitude != nil && ride.originLongitude != nil && ride.meetingPointLatitude != nil && ride.meetingPointLongitude != nil){
            CLLocationCoordinate2D originCoordinate;
            CLLocationCoordinate2D meetingPointCoordinate;
            originCoordinate.latitude = [ride.originLatitude doubleValue];
            originCoordinate.longitude = [ride.originLongitude doubleValue];
            meetingPointCoordinate.latitude = [ride.meetingPointLatitude doubleValue];
            meetingPointCoordinate.longitude = [ride.meetingPointLongitude doubleValue];
            [VCMapQuestRouting route:destinationCoordinate to:departureCoordinate region:_map.region success:^(MKPolyline *polyline, MKCoordinateRegion region) {
                _routeToMeetingPointOverlay = polyline;
                [_map addOverlay:_routeToMeetingPointOverlay];
            } failure:^{
                NSLog(@"%@", @"Error talking with MapQuest routing API");
            }];
        }
    }
    
}

- (void) clearMap {
    [_map removeAnnotation:_pickupAnnotation];
    [_map removeAnnotation:_dropOffAnnotation];
    [_map removeOverlay:_routeOverlay];
    [_map removeOverlay:_routeToMeetingPointOverlay];
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
        } else if ([overlay isEqual:_routeToMeetingPointOverlay]){
            aRenderer.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.7];
            aRenderer.lineWidth = 4;
            aRenderer.lineDashPattern = @[[NSNumber numberWithInt:5], [NSNumber numberWithInt:2]];
        }
        
        return aRenderer;
    }
    
    return nil;
}

@end
