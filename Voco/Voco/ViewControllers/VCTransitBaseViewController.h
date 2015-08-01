//
//  VCRideViewController.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "MBRegion.h"
#import "Fare.h"
#import "VCCenterViewBaseViewController.h"

@interface VCTransitBaseViewController : VCCenterViewBaseViewController

@property (strong, nonatomic) Transit * transit;

// Map
@property (strong, nonatomic) RMMapView * map;
@property (strong, nonatomic) RMAnnotation * routeOverlay;
@property (strong, nonatomic) CLGeocoder * geocoder;
@property (nonatomic) MBRegion *rideRegion;


- (void) showSuggestedRoute;
- (void) showSuggestedRoute: (CLLocation *) from to: (CLLocation *) to;
- (void) clearMap;
- (void) clearRoute;

- (void) resetInterface;
- (void) zoomToCurrentLocation;


- (IBAction)didTapCurrentLocationButton:(id)sender;

@end
