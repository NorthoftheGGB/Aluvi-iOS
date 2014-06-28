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
#import <ActionSheetPicker.h>
#import "VCUserState.h"
#import "VCInterfaceModes.h"
#import "VCRiderApi.h"
#import "VCMapQuestRouting.h"
#import "VCRideRequestCreated.h"
#import "Car.h"
#import "Driver.h"
#import "DTLazyImageView.h"

#define kStepSetDepartureLocation 1
#define kStepSetDestinationLocation 2

@interface VCRiderHomeViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mapCenterPin;
@property (weak, nonatomic) IBOutlet UIView *departureEntryView;
@property (weak, nonatomic) IBOutlet UIView *destinationEntryView;
@property (weak, nonatomic) IBOutlet UIButton *onDemandButton;
@property (weak, nonatomic) IBOutlet UIButton *commuteButton;
@property (weak, nonatomic) IBOutlet UIView *locationConfirmationAnnotation;
@property (weak, nonatomic) IBOutlet UIButton *locationConfirmationButtonLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;
@property (weak, nonatomic) IBOutlet UIButton *morningOrEveningButton;
@property (weak, nonatomic) IBOutlet UIButton *arrivalTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *scheduleRideButton;

// Ride Details Drawer
@property (strong, nonatomic) IBOutlet UIView *rideDetailsDrawer;
@property (strong, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *carTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentFareLabel;
@property (strong, nonatomic) IBOutlet DTLazyImageView *driverPhotoImageView;
@property (strong, nonatomic) IBOutlet DTLazyImageView *licensePlateImageView;
@property (weak, nonatomic) IBOutlet UILabel *licensePlatNumberLabel;

// Map
@property (strong, nonatomic) MKMapView * map;
@property (strong, nonatomic) MKPolyline * routeOverlay;
@property (strong, nonatomic) CLGeocoder * geocoder;

@property (nonatomic) NSInteger step;



- (IBAction)didTapCallDriverButton:(id)sender;
- (IBAction)didTapCommute:(id)sender;
- (IBAction)didTapOnDemand:(id)sender;
- (IBAction)didTapConfirmLocation:(id)sender;
- (IBAction)didTapCancel:(id)sender;
- (IBAction)didTapMorningOrEveningButton:(id)sender;
- (IBAction)didTapArrivalTimeButton:(id)sender;
- (IBAction)didTapScheduleRideButton:(id)sender;


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
    self.title = @"Home";
    
    _map = [[MKMapView alloc] initWithFrame:self.view.frame];
    _map.delegate = self;
    _map.showsUserLocation = YES;
    _map.userTrackingMode = YES;
    [self.view insertSubview:_map atIndex:0];
    [self resetRequestInterface];
    if(_ride != nil){
        [self placeRideDetailsDrawerInPickupMode];
        [self showRideDetailsDrawer];
        [self showSuggestedRoute];
        self.title = _ride.routeDescription;
    }
    
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

- (void) showSuggestedRoute {
    
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
    
}


- (IBAction)didTapCommute:(id)sender {
    [self showRouteRequestInterface];
    
    _ride = (Ride *) [NSEntityDescription insertNewObjectForEntityForName:@"Ride" inManagedObjectContext:[VCCoreData managedObjectContext]];
    _ride.requestType = RIDE_REQUEST_TYPE_COMMUTER;
    _morningOrEveningButton.hidden = NO;
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
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:departureLocation.latitude  longitude:departureLocation.longitude];
        if (!_geocoder)
            _geocoder = [[CLGeocoder alloc] init];
        [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            MKPlacemark * placemark = [placemarks objectAtIndex:0];
            _ride.originPlaceName = [placemark name];
        }];

        
        
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(departureLocation.latitude, departureLocation.longitude);
        myAnnotation.title = @"Pickup Location";
        myAnnotation.subtitle = @"Click to change";
        [_map addAnnotation:myAnnotation];
        
        [_locationConfirmationButtonLabel setTitle:@"Set Drop Off Location" forState:UIControlStateNormal];
        
        [_departureEntryView removeFromSuperview];
        CGRect frame = _destinationEntryView.frame;
        frame.origin.y = 20;
        _destinationEntryView.frame = frame;
        [self.view addSubview:_destinationEntryView];
        
    } else if (_step == kStepSetDestinationLocation) {
        CLLocationCoordinate2D destinationLocation = [_map centerCoordinate];
        _ride.destinationLatitude = [NSNumber numberWithDouble: destinationLocation.latitude];
        _ride.destinationLongitude = [NSNumber numberWithDouble: destinationLocation.longitude];
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:destinationLocation.latitude  longitude:destinationLocation.longitude];
        if (!_geocoder)
            _geocoder = [[CLGeocoder alloc] init];
        [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            MKPlacemark * placemark = [placemarks objectAtIndex:0];
            _ride.destinationPlaceName = [placemark name];
        }];
        
        
        [self showSuggestedRoute];
        
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
            [VCRiderApi requestRide:_ride
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                VCRideRequestCreated * rideRequestCreatedResponse = mappingResult.firstObject;
                                _ride.request_id = rideRequestCreatedResponse.rideRequestId;
                                _ride.requestedTimestamp = [NSDate date];
                                [VCCoreData saveContext];
                                [hud hide:YES];
                                // TODO: Don't show an alert, show a HUD
                                [UIAlertView showWithTitle:@"Requested!" message:@"We are finding your driver now!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                    
                                }];
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                [hud hide:YES];
                            }];
        } else if ( [ _ride.requestType isEqualToString:RIDE_REQUEST_TYPE_COMMUTER]) {
            // Commuter Confirmation
            
        }
        
    }
}


- (IBAction)didTapCancel:(id)sender {
    
    if(!_ride.request_id || _ride.request_id == nil){
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
        [self resetRequestInterface];
        [hud hide:YES];
        [WRUtilities criticalError:error];
        
    }];
    
}

- (IBAction)didTapMorningOrEveningButton:(id)sender {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d"];
    NSString * dayString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray *options = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Morning Of %@", dayString],
                        [NSString stringWithFormat:@"Evening of %@", dayString], nil];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select morning or evening"
                                            rows:options
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [_morningOrEveningButton setTitle:[options objectAtIndex:selectedIndex ] forState:UIControlStateNormal];
                                           _arrivalTimeButton.hidden = NO;
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

- (IBAction)didTapArrivalTimeButton:(id)sender {
    NSArray *morningOptions = @[
                                @"6:00", @"6:30", @"7:00", @"7:30",
                                @"8:00", @"8:30", @"9:00", @"9:30",
                                @"10:00", @"10:30", @"11:00", @"11:30",
                                @"12:00"];
    NSArray *evengingOptions = @[
                                 @"3:00", @"3:30", @"4:00", @"4:30",
                                 @"5:00", @"5:30", @"6:00", @"6:30",
                                 @"7:00", @"7:30", @"8:00", @"8:30",
                                 @"9:00"];
    NSArray * options;
    if([_morningOrEveningButton.titleLabel.text rangeOfString:@"Morning" options:NSCaseInsensitiveSearch].location == 0){
        options = morningOptions;
    } else {
        options = evengingOptions;
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select your arrival time"
                                            rows:options
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSString * title = [NSString stringWithFormat:@"Arrive By: %@", [options objectAtIndex:selectedIndex] ];
                                           [_arrivalTimeButton setTitle:title forState:UIControlStateNormal];
                                           _scheduleRideButton.hidden = NO;
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

- (IBAction)didTapScheduleRideButton:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Requesting Ride";
    
    // VC RidesAPI
    [VCRiderApi requestRide:_ride success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        VCRideRequestCreated * rideRequestCreatedResponse = mappingResult.firstObject;
        _ride.request_id = rideRequestCreatedResponse.rideRequestId;
        [VCCoreData saveContext];
        [hud hide:YES];
        [UIAlertView showWithTitle:@"Ride Requested"
                           message:@"Your commuter ride has been requested with our system.  We will notify you when a ride share has been found"
                 cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                     [self resetRequestInterface];
                 }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [hud hide:YES];
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
    [_locationConfirmationButtonLabel setTitle:@"Set Pick Up Location" forState:UIControlStateNormal];
    _mapCenterPin.hidden = YES;
    _locationConfirmationAnnotation.hidden = YES;
    _destinationEntryView.hidden = YES;
    _departureEntryView.hidden = YES;
    _onDemandButton.hidden = NO;
    _commuteButton.hidden = NO;
    _cancelRideButton.hidden = YES;
    _step = kStepSetDepartureLocation;
    _arrivalTimeButton.hidden = YES;
    _morningOrEveningButton.hidden = YES;
    _scheduleRideButton.hidden = YES;
    if(_routeOverlay != nil) {
        [_map removeOverlay:_routeOverlay];
    }
    [self hideRideDetailsDrawer];
}

- (void) placeRideDetailsDrawerInPickupMode {
    _currentFareLabel.text = @"Ride not started";
    _driverNameLabel.text= _ride.driver.fullName;
    _carTypeLabel.text = _ride.car.description;
    _licensePlatNumberLabel.text = _ride.car.licensePlate;
    [_driverPhotoImageView loadImageAtURL:[NSURL URLWithString:_ride.driver.driversLicenseUrl]];
    
}

- (void) placeRideDetailsDrawerInRidingMode {
    _currentFareLabel.text = @"Ride started";
}

- (void) showRideDetailsDrawer {
    [UIView transitionWithView:self.view
                      duration:.45f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        _rideDetailsDrawer.frame = CGRectMake(0, self.view.frame.size.height - _rideDetailsDrawer.frame.size.height, _rideDetailsDrawer.frame.size.width, _rideDetailsDrawer.frame.size.height);
                        [self.view addSubview:_rideDetailsDrawer];
                    } completion:nil];
  
    
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
        [UIView transitionWithView:self.view
                          duration:.45f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [_rideDetailsDrawer removeFromSuperview];
                        } completion:nil];
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
