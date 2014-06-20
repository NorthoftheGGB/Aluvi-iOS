//
//  VCRiderHomeViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderHomeViewController.h"
#import <MapKit/MapKit.h>
#import <MBProgressHUD.h>
#import "VCUserState.h"
#import "VCInterfaceModes.h"
#import "Ride.h"
#import "VCRiderApi.h"
#import "VCMapQuestRouting.h"
#import "VCRideRequestCreated.h"

#define kStepSetDepartureLocation 1
#define kStepSetDestinationLocation 2

@interface VCRiderHomeViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mapCenterPin;
@property (weak, nonatomic) IBOutlet UIView *departureEntryView;
@property (weak, nonatomic) IBOutlet UIView *destinationEntryView;
@property (weak, nonatomic) IBOutlet UIButton *onDemandButton;
@property (weak, nonatomic) IBOutlet UIButton *commuteButton;
@property (weak, nonatomic) IBOutlet UIView *locationConfirmationAnnotation;
@property (weak, nonatomic) IBOutlet UILabel *locationConfirmationLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;

// Ride Details Drawer
@property (strong, nonatomic) IBOutlet UIView *rideDetailsDrawer;
@property (strong, nonatomic) IBOutlet UILabel *riderNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *carTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentFareLabel;
@property (strong, nonatomic) IBOutlet UIImageView *driverPhotoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *licensePlateImageView;

- (IBAction)didTapCallDriverButton:(id)sender;

// Map
@property (strong, nonatomic) MKMapView * map;
@property (strong, nonatomic) MKPolyline * routeOverlay;

@property (nonatomic) NSInteger step;
@property (strong, nonatomic) Ride * ride;

- (IBAction)didTapCommute:(id)sender;
- (IBAction)didTapOnDemand:(id)sender;
- (IBAction)didTapConfirmLocation:(id)sender;
- (IBAction)didTapCancel:(id)sender;

@end

@implementation VCRiderHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _step = kStepSetDepartureLocation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapCenterPin.hidden = YES;
    _locationConfirmationAnnotation.hidden = YES;
    _cancelRideButton.hidden = YES;
    
    _map = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _map.delegate = self;
    _map.showsUserLocation = YES;
    _map.userTrackingMode = YES;
    [self.view insertSubview:_map atIndex:0];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideFoundNotification:) name:@"ride_found" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideCancelledByDriverNotification:) name:@"ride_cancelled_by_driver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideComplete:) name:@"ride_complete" object:nil];
    
}

- (void) viewWillDisppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) rideFoundNotification:(id) sender{
    [[VCCoreData managedObjectContext] refreshObject:_ride mergeChanges:YES];
    [self showRideDetailsDrawer];
}

- (void) rideCancelledByDriverNotification:(id) sender{
    [[VCCoreData managedObjectContext] refreshObject:_ride mergeChanges:YES];
    [self resetRequestInterface];
}

- (void) rideComplete:(id) sender{
    [self resetRequestInterface];
    _ride = nil;
}



- (IBAction)didTapCommute:(id)sender {
    [self showRouteRequestInterface];
    
    _ride = (Ride *) [NSEntityDescription insertNewObjectForEntityForName:@"Ride" inManagedObjectContext:[VCCoreData managedObjectContext]];
    _ride.requestType = RIDE_REQUEST_TYPE_COMMUTER;
}

- (IBAction)didTapOnDemand:(id)sender {
    [self showRouteRequestInterface];

    _ride = (Ride *) [NSEntityDescription insertNewObjectForEntityForName:@"Ride" inManagedObjectContext:[VCCoreData managedObjectContext]];
    _ride.requestType = RIDE_REQUEST_TYPE_ON_DEMAND;
    
    /*
    CGRect frame = _departureEntryView.frame;
    frame.origin.y = 20;
    _departureEntryView.frame = frame;
    [self.view addSubview:_departureEntryView];
     */
}

- (IBAction)didTapConfirmLocation:(id)sender {
    if(_step == kStepSetDepartureLocation){
        CLLocationCoordinate2D departureLocation = [_map centerCoordinate];
        _ride.originLatitude = [NSNumber numberWithDouble: departureLocation.latitude];
        _ride.originLongitude= [NSNumber numberWithDouble: departureLocation.longitude];
        _step = kStepSetDestinationLocation;
        
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(departureLocation.latitude, departureLocation.longitude);
        myAnnotation.title = @"Pickup Location";
        myAnnotation.subtitle = @"Click to change";
        [_map addAnnotation:myAnnotation];
        
        _locationConfirmationLabel.text = @"Set Drop Off Location";
        
        [_departureEntryView removeFromSuperview];
        CGRect frame = _destinationEntryView.frame;
        frame.origin.y = 20;
        _destinationEntryView.frame = frame;
        [self.view addSubview:_destinationEntryView];
        
    } else if (_step == kStepSetDestinationLocation) {
        CLLocationCoordinate2D destinationLocation = [_map centerCoordinate];
        _ride.destinationLatitude = [NSNumber numberWithDouble: destinationLocation.latitude];
        _ride.destinationLongitude = [NSNumber numberWithDouble: destinationLocation.longitude];
        
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
        
        
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(destinationLocation.latitude, destinationLocation.longitude);
        myAnnotation.title = @"Drop Off Location";
        myAnnotation.subtitle = @"Click to change";
        [_map addAnnotation:myAnnotation];
        
        _mapCenterPin.hidden = YES;
        _locationConfirmationAnnotation.hidden = YES;
        
        if([ _ride.requestType isEqualToString:RIDE_REQUEST_TYPE_ON_DEMAND]) {
        
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Requesting Ride";
        
        // VC RidesAPI
        [VCRiderApi requestRide:_ride success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            VCRideRequestCreated * rideRequestCreatedResponse = mappingResult.firstObject;
            _ride.request_id = rideRequestCreatedResponse.rideRequestId;
            [VCCoreData saveContext];
            [hud hide:YES];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [hud hide:YES];
        }];
        } else if ( [ _ride.requestType isEqualToString:RIDE_REQUEST_TYPE_COMMUTER]) {
            // Commuter Confirmation
            
        }
        
    }
}


- (IBAction)didTapCancel:(id)sender {
    
    if(!_ride.request_id){
        [self resetRequestInterface];
        return;
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Canceling Ride";
    

    // VC RidesAPI
    [VCRiderApi cancelRide:_ride success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self resetRequestInterface];
        [hud hide:YES];
        
        [UIAlertView showWithTitle:@"Ride Cancelled" message:@"Your ride has been cancelled" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        [self resetRequestInterface];

        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [WRUtilities criticalError:error];
        [self resetRequestInterface];

    }];
    
}

#pragma mark Interface

- (void) showRouteRequestInterface {
    _onDemandButton.hidden = YES;
    _commuteButton.hidden = YES;
    _mapCenterPin.hidden = NO;
    _locationConfirmationAnnotation.hidden = NO;
    _cancelRideButton.hidden = NO;
}

- (void) resetRequestInterface {
    [_map removeAnnotations:_map.annotations];
    _locationConfirmationLabel.text = @"Set Pick Up Location";
    _mapCenterPin.hidden = YES;
    _locationConfirmationAnnotation.hidden = YES;
    _destinationEntryView.hidden = YES;
    _departureEntryView.hidden = YES;
    _onDemandButton.hidden = NO;
    _commuteButton.hidden = NO;
    _cancelRideButton.hidden = YES;
    _step = kStepSetDepartureLocation;
    if(_routeOverlay != nil) {
        [_map removeOverlay:_routeOverlay];
    }
    [self hideRideDetailsDrawer];
}

- (void) showRideDetailsDrawer {
    _rideDetailsDrawer.frame = CGRectMake(0, self.view.frame.size.height - _rideDetailsDrawer.frame.size.height, _rideDetailsDrawer.frame.size.width, _rideDetailsDrawer.frame.size.height);
    [self.view addSubview:_rideDetailsDrawer];
    
    /*
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_rideDetailsDrawer
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:0]];
     */
}

- (void) hideRideDetailsDrawer {
    if( _rideDetailsDrawer.superview != nil) {
        [_rideDetailsDrawer removeFromSuperview];
    }
}

#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer*    aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
        
        aRenderer.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        aRenderer.lineWidth = 3;
        
        return aRenderer;
    }
    
    return nil;
}

- (IBAction)didTapCallDriverButton:(id)sender {
}
@end
