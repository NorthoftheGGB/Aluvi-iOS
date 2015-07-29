//
//  VCRideViewController.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <MapKit/MapKit.h>
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "MBRegion.h"
#import "Fare.h"
#import "VCCenterViewBaseViewController.h"

@interface VCTransitBaseViewController : VCCenterViewBaseViewController

@property (strong, nonatomic) Transit * transit;

// Map
//@property (strong, nonatomic) MKMapView * map;
@property (strong, nonatomic) RMMapView * map;
@property (strong, nonatomic) NSArray * routeOverlay;
@property (strong, nonatomic) CLGeocoder * geocoder;
//@property (strong, nonatomic) MKPointAnnotation * dropOffAnnotation;
//@property (strong, nonatomic) MKPointAnnotation * meetingPointAnnotation;
@property (nonatomic) MBRegion *rideRegion;


- (void) showSuggestedRoute;
- (void) showSuggestedRoute: (CLLocation *) from to: (CLLocation *) to;
//- (void) annotateMeetingPoint: (CLLocation *) meetingPoint andDropOffPoint: (CLLocation *) dropOffPoint;
- (void) clearMap;
- (void) clearRoute;

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay;

- (void) resetInterface;
- (void) zoomToCurrentLocation;


- (IBAction)didTapCurrentLocationButton:(id)sender;

@end
