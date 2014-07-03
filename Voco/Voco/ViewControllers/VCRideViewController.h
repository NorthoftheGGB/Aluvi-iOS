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

@interface VCRideViewController : UIViewController

@property (strong, nonatomic) Trip * transport;

// Map
@property (strong, nonatomic) MKMapView * map;
@property (strong, nonatomic) MKPolyline * routeOverlay;
@property (strong, nonatomic) MKPolyline * routeToMeetingPointOverlay;
@property (strong, nonatomic) CLGeocoder * geocoder;
@property (strong, nonatomic) MKPointAnnotation * dropOffAnnotation;
@property (strong, nonatomic) MKPointAnnotation * pickupAnnotation;
@property (nonatomic) MKCoordinateRegion rideRegion;

- (void) showSuggestedRoute;
- (void) showRideLocations;
- (void) clearMap;

@end
