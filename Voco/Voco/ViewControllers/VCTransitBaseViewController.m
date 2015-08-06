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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        if (!self.geocoder) {
            
            self.geocoder = [[CLGeocoder alloc] init];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset Map"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(resetInterface)];
    self.viewDeckController.navigationItem.rightBarButtonItem = anotherButton;

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showSuggestedRoute {
    
    [self showSuggestedRoute:nil to:nil];
}

- (void) showSuggestedRoute: (CLLocation *) from to: (CLLocation *) to {
    
    self.map.userTrackingMode = RMUserTrackingModeNone;

    CLLocationCoordinate2D dropOffPointCoordinate;
    CLLocationCoordinate2D meetingPointCoordinate;
    dropOffPointCoordinate.latitude = from.coordinate.latitude;
    dropOffPointCoordinate.longitude = from.coordinate.longitude;
    meetingPointCoordinate.latitude = to.coordinate.latitude;
    meetingPointCoordinate.longitude = to.coordinate.longitude;
    
    NSData *regionData = [[NSUserDefaults standardUserDefaults] objectForKey:@"route_region"];
    if (regionData != nil) {

        MBRegion *region = [NSKeyedUnarchiver unarchiveObjectWithData:regionData];
        
        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:region.topLocation.latitude longitude:region.topLocation.longitude];
        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:region.bottomLocation.latitude longitude:region.bottomLocation.longitude];
        CLLocationDistance d = [pointALocation distanceFromLocation:pointBLocation];
        MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(region.topLocation, 2*d, 2*d);

        if ([self isCoordinate:meetingPointCoordinate insideRegion:r] || [self isCoordinate:dropOffPointCoordinate insideRegion:r]) {
            
            // Unarchive last valid route and use that for MapBox
            NSData *polylineData = [[NSUserDefaults standardUserDefaults] objectForKey:@"route_polyline"];
            if (polylineData != nil) {
                
                NSArray *polyline = [NSKeyedUnarchiver unarchiveObjectWithData:polylineData];
                
                RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                                      coordinate:((CLLocation *)[polyline objectAtIndex:0]).coordinate
                                                                        andTitle:@"suggested_route"];
                annotation.userInfo = polyline;
                [annotation setBoundingBoxFromLocations:polyline];
                
                [self.map addAnnotation:annotation];
                
                _routeOverlay = annotation;
            }
            
            NSData *regionData = [[NSUserDefaults standardUserDefaults] objectForKey:@"route_region"];
            if (regionData != nil) {
                
                // Delay execution of my block for the MapBox software to fully load and move to correct place on the map
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25), dispatch_get_main_queue(), ^{
                    
                    MBRegion *region = [NSKeyedUnarchiver unarchiveObjectWithData:regionData];
                    
                    self.rideRegion = region;
                    [self.map zoomWithLatitudeLongitudeBoundsSouthWest:region.topLocation northEast:region.bottomLocation animated:NO];
                });
            }
        }
        
        return;
    }
    
    //MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText= @"Fetching Route";
    [VCMapQuestRouting route:meetingPointCoordinate to:dropOffPointCoordinate success:^(NSArray *polyline, MBRegion *region) {
        
        if (_routeOverlay != nil) {
            
            [self.map removeAnnotation:_routeOverlay];
        }
        
        if (region.topLocation.latitude == 0 || region.bottomLocation.longitude == 0) {
            
            return;
        }
        
        RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                              coordinate:((CLLocation *)[polyline objectAtIndex:0]).coordinate
                                                                andTitle:@"suggested_route"];
        annotation.userInfo = polyline;
        [annotation setBoundingBoxFromLocations:polyline];
        
        [self.map addAnnotation:annotation];

        _routeOverlay = annotation;
        
        // TODO: need to adjust region
        self.rideRegion = region;
        [self.map zoomWithLatitudeLongitudeBoundsSouthWest:region.topLocation northEast:region.bottomLocation animated:NO];
        
        // Store off last successfully region and polyline
        NSData *storedRegion = [NSKeyedArchiver archivedDataWithRootObject:region];
        [[NSUserDefaults standardUserDefaults] setObject:storedRegion forKey:@"route_region"];

        NSData *storedPolyline = [NSKeyedArchiver archivedDataWithRootObject:polyline];
        [[NSUserDefaults standardUserDefaults] setObject:storedPolyline forKey:@"route_polyline"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[hud hide:YES];
    } failure:^{
        
        // [UIAlertView showWithTitle:@"Network Error" message:@"Woops, we couldn't contact the routing server.  You can still manage your ride though!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        NSLog(@"%@", @"Error talking with MapQuest routing API");
        
        // Unarchive last valid route and use that for MapBox
        NSData *polylineData = [[NSUserDefaults standardUserDefaults] objectForKey:@"route_polyline"];
        if (polylineData != nil) {
            
            NSArray *polyline = [NSKeyedUnarchiver unarchiveObjectWithData:polylineData];
            
            RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                                  coordinate:((CLLocation *)[polyline objectAtIndex:0]).coordinate
                                                                    andTitle:@"suggested_route"];
            annotation.userInfo = polyline;
            [annotation setBoundingBoxFromLocations:polyline];
            
            [self.map addAnnotation:annotation];
            
            _routeOverlay = annotation;
        }

        NSData *regionData = [[NSUserDefaults standardUserDefaults] objectForKey:@"route_region"];
        if (regionData != nil) {
            
            MBRegion *region = [NSKeyedUnarchiver unarchiveObjectWithData:regionData];
            
            self.rideRegion = region;
            [self.map zoomWithLatitudeLongitudeBoundsSouthWest:region.topLocation northEast:region.bottomLocation animated:NO];
        }

        //[hud hide:YES];
    }];
    
}

-(BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate insideRegion:(MKCoordinateRegion)region {
    
    CLLocationCoordinate2D center   = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    return(coordinate.latitude  >= northWestCorner.latitude &&
           coordinate.latitude  <= southEastCorner.latitude &&
           coordinate.longitude >= northWestCorner.longitude &&
           coordinate.longitude <= southEastCorner.longitude
           );
}

- (void) clearRoute {
    
    //[self.map removeOverlay:_routeOverlay];
    if (_routeOverlay != nil) {
        
        [self.map removeAnnotation:_routeOverlay];
    }
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
        
        [self.map setCenterCoordinate:CLLocationCoordinate2DMake(self.map.userLocation.location.coordinate.latitude, self.map.userLocation.coordinate.longitude) animated:NO];
        
        /*[self.map setRegion:MKCoordinateRegionMakeWithDistance(
                                                               CLLocationCoordinate2DMake(self.map.userLocation.location.coordinate.latitude, self.map.userLocation.coordinate.longitude),
                                                               500, 500
                                                               )
                                                               animated: YES];
        */
    }
}


// IBOutlets
- (IBAction)didTapCurrentLocationButton:(id)sender {

    [self zoomToCurrentLocation];
}

@end
