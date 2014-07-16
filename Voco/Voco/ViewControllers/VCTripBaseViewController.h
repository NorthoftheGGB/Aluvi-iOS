//
//  VCRideViewController.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Request.h"

@interface VCTripBaseViewController : UIViewController

@property (strong, nonatomic) Trip * transport;

// Map
@property (strong, nonatomic) MKMapView * map;
@property (strong, nonatomic) MKPolyline * routeOverlay;
@property (strong, nonatomic) CLGeocoder * geocoder;
@property (strong, nonatomic) MKPointAnnotation * dropOffAnnotation;
@property (strong, nonatomic) MKPointAnnotation * meetingPointAnnotation;
@property (nonatomic) MKCoordinateRegion rideRegion;

- (void) showSuggestedRoute;
- (void) showSuggestedRoute: (CLLocation *) from to: (CLLocation *) to;
- (void) annotateMeetingPoint: (CLLocation *) meetingPoint andDropOffPoint: (CLLocation *) dropOffPoint;
- (void) clearMap;

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay;

- (void) resetInterface;
@end