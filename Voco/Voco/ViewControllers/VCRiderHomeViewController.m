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
#import <BlocksKit.h>
#import "VCUserState.h"
#import "VCInterfaceModes.h"
#import "VCRiderApi.h"
#import "VCMapQuestRouting.h"
#import "VCRideRequestCreated.h"
#import "Car.h"
#import "Driver.h"
#import "DTLazyImageView.h"
#import "VCLabel.h"
#import "VCLocationSearchViewController.h"
#import "VCCommuterHud.h"
#import "NSDate+Pretty.h"
#define kStepSetDepartureLocation 1
#define kStepSetDestinationLocation 2
#define kStepConfirmRequest 3
#define kStepDone 4

@interface VCRiderHomeViewController () <MKMapViewDelegate, VCLocationSearchViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mapCenterPin;
@property (weak, nonatomic) IBOutlet UIView *departureEntryView;
@property (weak, nonatomic) IBOutlet UIView *destinationEntryView;
@property (weak, nonatomic) IBOutlet UIButton *onDemandButton;
@property (weak, nonatomic) IBOutlet UIButton *commuteButton;
@property (weak, nonatomic) IBOutlet UIView *locationConfirmationAnnotation;
@property (weak, nonatomic) IBOutlet UIButton *locationConfirmationButtonLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;
@property (strong, nonatomic) MBProgressHUD * progressHUD;

// Ride Details Drawer
@property (strong, nonatomic) IBOutlet UIView *rideDetailsDrawer;
@property (strong, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *carTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentFareLabel;
@property (strong, nonatomic) IBOutlet DTLazyImageView *driverPhotoImageView;
@property (strong, nonatomic) IBOutlet DTLazyImageView *licensePlateImageView;
@property (weak, nonatomic) IBOutlet UILabel *licensePlatNumberLabel;

// Commuter Mode
@property (weak, nonatomic) IBOutlet UIButton *morningOrEveningButton;
@property (weak, nonatomic) IBOutlet UIButton *arrivalTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *scheduleRideButton;
@property (strong, nonatomic) IBOutlet VCCommuterHud *commuterHUD;

// Data Entry
@property (nonatomic) NSInteger step;
@property (strong, nonatomic) NSDate * desiredArrivalDateTime;
@property (strong, nonatomic) NSTimer * timer;

//Location HUD
@property (strong, nonatomic) IBOutlet UIView *locationHud;
@property (strong, nonatomic) IBOutlet VCLabel *currentAddressLabel;
@property (strong, nonatomic) IBOutlet VCLabel *locationTypeLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *geocodingActivityIndicator;
- (IBAction)didTapCurrentLocationButton:(id)sender;
- (IBAction)didTapSearchButton:(id)sender;

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


- (void) setRequest:(Request *)ride {
    _request = ride;
    self.transport = ride;
}

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
    
    [self resetRequestInterface];
    
    if(self.request != nil){
        [self updateInterfaceForTrip];
    }
    
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = self.map.userLocation.coordinate.latitude;
    mapRegion.center.longitude = self.map.userLocation.coordinate.longitude;
    mapRegion.span.latitudeDelta = 0.02;
    mapRegion.span.longitudeDelta = 0.02;
    [self.map setRegion:mapRegion animated: YES];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDemandRideFoundNotification:) name:@"ride_found" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commuterRideInvokedNotification:) name:@"commuter_ride_invoked" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideNotFoundNotification:) name:@"ride_not_found" object:nil];
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

- (void) onDemandRideFoundNotification:(id) sender{
    [[VCCoreData managedObjectContext] refreshObject:self.request mergeChanges:YES];
    [self showRideDetailsDrawer];
    if(_progressHUD != nil) {
        [_progressHUD hide:YES];
    }
    
}

- (void) commuterRideInvokedNotification:(id) sender{
    Request * request = ((NSNotification *) sender).object;
    self.request = request;
    [self showCommuterRideDetailsOverlay];
    [self showLocationHudIfNotDisplayed];
    
}

- (void) rideNotFoundNotification:(id) sender{
    NSAssert(0, @"Not implemented");
}

- (void) rideCancelledByDriverNotification:(id) sender{
    [[VCCoreData managedObjectContext] refreshObject:self.request mergeChanges:YES];
    [self resetRequestInterface];
}

- (void) rideComplete:(id) sender{
    [self resetRequestInterface];
    self.request = nil;
}


- (IBAction)didTapCommute:(id)sender {
    self.request = (Request *) [NSEntityDescription insertNewObjectForEntityForName:@"Request" inManagedObjectContext:[VCCoreData managedObjectContext]];
    self.request.requestType = kRideRequestTypeCommuter;
    self.transport = self.request;
    
    [self showRouteRequestInterface];
    [self reverseGeocodeMapCenterForHud];
    [self showLocationHudIfNotDisplayed];
    _morningOrEveningButton.hidden = NO;
    _locationTypeLabel.text = @"Departure Location";
    _currentAddressLabel.text = nil;
    self.step = kStepSetDepartureLocation;
    
}

- (IBAction)didTapOnDemand:(id)sender {
    self.request = (Request *) [NSEntityDescription insertNewObjectForEntityForName:@"Request" inManagedObjectContext:[VCCoreData managedObjectContext]];
    self.request.requestType = kRideRequestTypeOnDemand;
    self.transport = self.request;
    
    [self showRouteRequestInterface];
    [self reverseGeocodeMapCenterForHud];
    [self showLocationHudIfNotDisplayed];
    _locationTypeLabel.text = @"Pickup Location";
    _currentAddressLabel.text = nil;
    self.step = kStepSetDepartureLocation;
    
}


- (void) showLocationHudIfNotDisplayed {
    if(_locationHud.superview == nil){
        CGRect frame = _locationHud.frame;
        frame.origin.x = 0;
        frame.origin.y = 64;
        _locationHud.frame = frame;
        [self.view addSubview:_locationHud];
    }
}

- (void) hideRequestInterface {
    [self resetRequestInterface];
    _onDemandButton.hidden = YES;
    _commuteButton.hidden = YES;
}


- (void)updateInterfaceForTrip
{
    [self hideRequestInterface];
    
    [self showLocationHudIfNotDisplayed];
    
    if(![self.request.state isEqualToString:kCreatedState]){
        _step = kStepDone;
    }
    
    // Setup interface for ride state
    if([self.request.requestType isEqualToString:kRideRequestTypeOnDemand]){
        
        [self showSuggestedRoute];
        [self annotateMeetingPoint:[[CLLocation alloc] initWithLatitude:[self.request.meetingPointLatitude doubleValue]
                                                              longitude:[self.request.meetingPointLongitude doubleValue]]
                   andDropOffPoint:[[CLLocation alloc] initWithLatitude:[self.request.dropOffPointLatitude doubleValue]
                                                              longitude:[self.request.dropOffPointLongitude doubleValue]]];
        [self placeRideDetailsDrawerInPickupMode];
        [self showRideDetailsDrawer];
        
    } else if ([self.request.requestType isEqualToString:kRideRequestTypeCommuter]){
        
        [self showSuggestedRoute];
        
        if([@[kCreatedState, kRequestedState] containsObject:self.request.state]){
            [self showRequestedModeInterface];
            
            [self annotateMeetingPoint:[[CLLocation alloc] initWithLatitude:[self.request.originLatitude doubleValue]
                                                                  longitude:[self.request.originLongitude doubleValue]]
                       andDropOffPoint:[[CLLocation alloc] initWithLatitude:[self.request.destinationLatitude doubleValue]
                                                                  longitude:[self.request.destinationLongitude doubleValue]]];
            
        } else if([self.request.state isEqualToString:kScheduledState]){
            //[self showScheduledModeInterface];
            [self annotateMeetingPoint:[[CLLocation alloc] initWithLatitude:[self.request.meetingPointLatitude doubleValue]
                                                                  longitude:[self.request.meetingPointLongitude doubleValue]]
                       andDropOffPoint:[[CLLocation alloc] initWithLatitude:[self.request.dropOffPointLatitude doubleValue]
                                                                  longitude:[self.request.dropOffPointLongitude doubleValue]]];
            
        }
        
    }
    self.title = self.request.routeDescription;
}




- (void) showCommuterRideDetailsOverlay {
    self.commuterHUD.meetingPointLabel.text = self.request.meetingPointPlaceName;
    self.commuterHUD.dropOffPointLabel.text = self.request.dropOffPointPlaceName;
    self.commuterHUD.meetingTimeLabel.text = [self.request.pickupTime pretty];
    [self.view addSubview:self.commuterHUD];
    [self updateInterfaceForTrip];
}

- (IBAction)didTapConfirmLocation:(id)sender {
    if(_step == kStepSetDepartureLocation){
        CLLocationCoordinate2D departureLocation = [self.map centerCoordinate];
        self.request.originLatitude = [NSNumber numberWithDouble: departureLocation.latitude];
        self.request.originLongitude= [NSNumber numberWithDouble: departureLocation.longitude];
        _step = kStepSetDestinationLocation;
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:departureLocation.latitude  longitude:departureLocation.longitude];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            MKPlacemark * placemark = [placemarks objectAtIndex:0];
            self.request.originPlaceName = [placemark name];
            self.currentAddressLabel.text = [placemark name];
        }];
        
        
        
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(departureLocation.latitude, departureLocation.longitude);
        myAnnotation.subtitle = @"Click to change";
        
        [_locationConfirmationButtonLabel setTitle:@"Set Drop-off Location" forState:UIControlStateNormal];
        if( [self.request.requestType isEqualToString:kRideRequestTypeOnDemand]){
            _locationTypeLabel.text = @"Drop-off Location";
            myAnnotation.title = @"Pickup Location";
            
        } else if ([self.request.requestType isEqualToString:kRideRequestTypeCommuter]){
            _locationTypeLabel.text = @"Destination Location";
            myAnnotation.title = @"Departure Location";
        }
        
        [self.map addAnnotation:myAnnotation];
        
        
        [_departureEntryView removeFromSuperview];
        CGRect frame = _destinationEntryView.frame;
        frame.origin.y = 20;
        _destinationEntryView.frame = frame;
        [self.view addSubview:_destinationEntryView];
        
    } else if (_step == kStepSetDestinationLocation) {
        CLLocationCoordinate2D destinationLocation = [self.map centerCoordinate];
        self.request.destinationLatitude = [NSNumber numberWithDouble: destinationLocation.latitude];
        self.request.destinationLongitude = [NSNumber numberWithDouble: destinationLocation.longitude];
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:destinationLocation.latitude  longitude:destinationLocation.longitude];
        if (!self.geocoder)
            self.geocoder = [[CLGeocoder alloc] init];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            MKPlacemark * placemark = [placemarks objectAtIndex:0];
            self.request.destinationPlaceName = [placemark name];
            self.currentAddressLabel.text = [placemark name];
        }];
        
        
        [self showSuggestedRoute];
        
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(destinationLocation.latitude, destinationLocation.longitude);
        myAnnotation.title = @"Drop-off Location";
        myAnnotation.subtitle = @"Click to change";
        [self.map addAnnotation:myAnnotation];
        
        [_locationConfirmationButtonLabel setTitle:@"Send Ride Request?" forState:UIControlStateNormal];
        self.mapCenterPin.hidden = YES;
        _step = kStepConfirmRequest;
        
    } else if (_step == kStepConfirmRequest) {
        _locationConfirmationAnnotation.hidden = YES;
        
        if([ self.request.requestType isEqualToString:kRideRequestTypeOnDemand]) {
            
            
            _progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            _progressHUD.labelText = @"Requesting Ride";
            
            // VC RidesAPI
            [VCRiderApi requestRide:self.request
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                VCRideRequestCreated * rideRequestCreatedResponse = mappingResult.firstObject;
                                self.request.request_id = rideRequestCreatedResponse.rideRequestId;
                                self.request.requestedTimestamp = [NSDate date];
                                [VCCoreData saveContext];
                                _progressHUD.labelText = @"We are finding your driver now!";
                                UITapGestureRecognizer *HUDSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hudSingleTap:)];
                                [_progressHUD addGestureRecognizer:HUDSingleTap];
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                [_progressHUD hide:YES];
                            }];
        } else if ( [ self.request.requestType isEqualToString:kRideRequestTypeCommuter]) {
            // Commuter Confirmation
            
        }
        
    }
}

- (void) hudSingleTap:(id) sender {
    [_progressHUD hide:YES];
    [self cancelRide];
}


- (IBAction)didTapCancel:(id)sender {
    
    [self cancelRide];
}

- (void) cancelRide {
    
    if(!self.request.request_id || self.request.request_id == nil){
        [self resetRequestInterface];
        return;
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Canceling Ride";
    
    
    // VC RidesAPI
    [VCRiderApi cancelRide:self.request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
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
    
    // Is it after the morning or evening commute?
    NSDate * firstSlotDate;
    NSDate * secondSlotDate;
    [dateFormatter setDateFormat:@"H"];
    NSString * currentHourString = [dateFormatter stringFromDate:[NSDate date]];
    int currentHour = [currentHourString intValue];
    NSArray *options;
    BOOL midday = NO;
    [dateFormatter setDateFormat:@"M/d"];
    if (currentHour < 11){
        // morning of same date
        firstSlotDate = [NSDate date];
        secondSlotDate = [NSDate date];
        options = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Morning Of %@", [dateFormatter stringFromDate:firstSlotDate]],
                   [NSString stringWithFormat:@"Evening of %@", [dateFormatter stringFromDate:secondSlotDate]], nil];
    } else if (currentHour > 11 && currentHour < 20) {
        midday = YES;
        // daytime of same date
        firstSlotDate = [NSDate date];
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
        secondSlotDate = nextDate;
        options = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Evening Of %@", [dateFormatter stringFromDate:firstSlotDate]],
                   [NSString stringWithFormat:@"Morning of %@", [dateFormatter stringFromDate:secondSlotDate]], nil];
    } else {
        // late night, following date
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
        firstSlotDate = nextDate;
        secondSlotDate = nextDate;
        options = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Morning Of %@", [dateFormatter stringFromDate:firstSlotDate]],
                   [NSString stringWithFormat:@"Evening of %@", [dateFormatter stringFromDate:secondSlotDate]], nil];
    }
    
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select morning or evening"
                                            rows:options
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [_morningOrEveningButton setTitle:[options objectAtIndex:selectedIndex ] forState:UIControlStateNormal];
                                           _arrivalTimeButton.hidden = NO;
                                           if(selectedIndex == 0){
                                               _desiredArrivalDateTime = firstSlotDate;
                                           } else if (selectedIndex == 1){
                                               _desiredArrivalDateTime = secondSlotDate;
                                           }
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
                                           
                                           NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:_desiredArrivalDateTime];
                                           _desiredArrivalDateTime = [[NSCalendar currentCalendar] dateFromComponents:comps];
                                           
                                           NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                                           
                                           if(options == morningOptions){
                                               dayComponent.hour = selectedIndex / 2 + 6;
                                               if(selectedIndex % 2 == 0){
                                                   dayComponent.minute = 0;
                                               } else {
                                                   dayComponent.minute = 30;
                                               }
                                           } else {
                                               dayComponent.hour = selectedIndex / 2 + 3 + 12;
                                               if(selectedIndex % 2 == 0){
                                                   dayComponent.minute = 0;
                                               } else {
                                                   dayComponent.minute = 30;
                                               }
                                           }
                                           
                                           NSCalendar *theCalendar = [NSCalendar currentCalendar];
                                           _desiredArrivalDateTime = [theCalendar dateByAddingComponents:dayComponent toDate:_desiredArrivalDateTime options:0];
                                           self.request.desiredArrival = _desiredArrivalDateTime;
                                           
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
    [VCRiderApi requestRide:self.request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        VCRideRequestCreated * rideRequestCreatedResponse = mappingResult.firstObject;
        self.request.request_id = rideRequestCreatedResponse.rideRequestId;
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


- (void) showRequestedModeInterface {
    _cancelRideButton.hidden = NO;
    _onDemandButton.hidden = YES;
    _commuteButton.hidden = YES;
    self.mapCenterPin.hidden = YES;
    _locationConfirmationAnnotation.hidden = YES;
}

- (void) showRouteRequestInterface {
    _onDemandButton.hidden = YES;
    _commuteButton.hidden = YES;
    self.mapCenterPin.hidden = NO;
    _locationConfirmationAnnotation.hidden = NO;
    _cancelRideButton.hidden = NO;
}

- (void) resetRequestInterface {
    [self.map removeAnnotations:self.map.annotations];
    [_locationConfirmationButtonLabel setTitle:@"Set Pick Up Location" forState:UIControlStateNormal];
    self.mapCenterPin.hidden = YES;
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
    if(self.routeOverlay != nil) {
        [self.map removeOverlay:self.routeOverlay];
    }
    [self hideRideDetailsDrawer];
    _geocodingActivityIndicator.hidden = YES;
    if(_locationHud.superview != nil) {
        [_locationHud removeFromSuperview];
    }
}

- (void) placeRideDetailsDrawerInPickupMode {
    _currentFareLabel.text = @"Ride not started";
    _driverNameLabel.text= self.request.driver.fullName;
    _carTypeLabel.text = self.request.car.description;
    _licensePlatNumberLabel.text = self.request.car.licensePlate;
    [_driverPhotoImageView loadImageAtURL:[NSURL URLWithString:self.request.driver.driversLicenseUrl]];
    
}

- (void) placeRideDetailsDrawerInRidingMode {
    _currentFareLabel.text = @"Ride started";
}

- (void) showRideDetailsDrawer {
    [UIView transitionWithView:self.view
                      duration:.45f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.rideDetailsDrawer.frame = CGRectMake(0, self.view.frame.size.height - self.rideDetailsDrawer.frame.size.height, self.rideDetailsDrawer.frame.size.width, self.rideDetailsDrawer.frame.size.height);
                        [self.view addSubview:self.rideDetailsDrawer];
                    } completion:nil];
    
    
    /*
     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.rideDetailsDrawer
     attribute:NSLayoutAttributeBottom
     relatedBy:NSLayoutRelationEqual
     toItem:self.view
     attribute:NSLayoutAttributeBottom
     multiplier:1
     constant:0]];
     */
}

- (void) hideRideDetailsDrawer {
    
    if( self.rideDetailsDrawer.superview != nil) {
        [UIView transitionWithView:self.view
                          duration:.45f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.rideDetailsDrawer removeFromSuperview];
                        } completion:nil];
    }
}



- (IBAction)didTapCurrentLocationButton:(id)sender {
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = self.map.userLocation.coordinate.latitude;
    mapRegion.center.longitude = self.map.userLocation.coordinate.longitude;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    [self.map setRegion:mapRegion animated: YES];
}

- (IBAction)didTapSearchButton:(id)sender {
    VCLocationSearchViewController * vc = [[VCLocationSearchViewController alloc] init];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)didTapCallDriverButton:(id)sender {
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if(_step == kStepSetDepartureLocation || _step == kStepSetDestinationLocation){
        
        [self reverseGeocodeMapCenterForHud];
        
        
    }
}

- (void) reverseGeocodeMapCenterForHud {
    
    if(_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer bk_scheduledTimerWithTimeInterval:.1 block:^(NSTimer * time) {
        [_geocodingActivityIndicator startAnimating];
        _geocodingActivityIndicator.hidden = NO;
        CLLocation * location = [[CLLocation alloc] initWithLatitude:self.map.centerCoordinate.latitude longitude:self.map.centerCoordinate.longitude];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            MKPlacemark * placemark = placemarks.firstObject;
            _currentAddressLabel.text = placemark.name;
            _geocodingActivityIndicator.hidden = YES;
            [_geocodingActivityIndicator stopAnimating];
            
        }];
        _timer = nil;
        
    } repeats:NO];
}

- (void) showSuggestedRoute {
    if([@[kCreatedState, kRequestedState] containsObject:_request.state]){
        
        CLLocation * from = [[CLLocation alloc] initWithLatitude:[_request.originLatitude doubleValue] longitude:[_request.originLongitude doubleValue]];
        CLLocation * to = [[CLLocation alloc] initWithLatitude:[_request.destinationLatitude doubleValue] longitude:[_request.destinationLongitude doubleValue]];
        [super showSuggestedRoute:from to:to];
        
    } else {
        [super showSuggestedRoute];
        
        
        // Walking route to Meeting Point
        CLLocationCoordinate2D originCoordinate;
        CLLocationCoordinate2D meetingPointCoordinate;
        originCoordinate.latitude = [_request.originLatitude doubleValue];
        originCoordinate.longitude = [_request.originLongitude doubleValue];
        meetingPointCoordinate.latitude = [_request.meetingPointLatitude doubleValue];
        meetingPointCoordinate.longitude = [_request.meetingPointLongitude doubleValue];
        if( originCoordinate.latitude  != meetingPointCoordinate.latitude
           && originCoordinate.longitude != meetingPointCoordinate.longitude ){
            [VCMapQuestRouting pedestrianRoute:originCoordinate to:meetingPointCoordinate success:^(MKPolyline *polyline, MKCoordinateRegion region) {
                _walkingRouteToMeetingPointOverlay = polyline;
                [self.map addOverlay:_walkingRouteToMeetingPointOverlay];
            } failure:^{
                NSLog(@"%@", @"Error talking with MapQuest routing API");
            }];
        }
        
        // Walking route from drop-off point
        CLLocationCoordinate2D destinationCoordinate;
        CLLocationCoordinate2D dropOffPointCoordinate;
        destinationCoordinate.latitude = [_request.destinationLatitude doubleValue];
        destinationCoordinate.longitude = [_request.destinationLongitude doubleValue];
        dropOffPointCoordinate.latitude = [_request.dropOffPointLatitude doubleValue];
        dropOffPointCoordinate.longitude = [_request.dropOffPointLongitude doubleValue];
        if( destinationCoordinate.latitude  != dropOffPointCoordinate.latitude
           && destinationCoordinate.longitude != dropOffPointCoordinate.longitude ){
            [VCMapQuestRouting pedestrianRoute:dropOffPointCoordinate to:destinationCoordinate success:^(MKPolyline *polyline, MKCoordinateRegion region) {
                _walkingRouteToDestinationOverlay = polyline;
                [self.map addOverlay:_walkingRouteToDestinationOverlay];
            } failure:^{
                NSLog(@"%@", @"Error talking with MapQuest routing API");
            }];
        }
    }
    
}

- (void) clearMap {
    [super clearMap];
    [self.map removeOverlay:_walkingRouteToMeetingPointOverlay];
    [self.map removeOverlay:_walkingRouteToDestinationOverlay];
    
}




#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer*   aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
        if ([overlay isEqual:_walkingRouteToMeetingPointOverlay]){
            aRenderer.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.7];
            aRenderer.lineWidth = 4;
            aRenderer.lineDashPattern = @[[NSNumber numberWithInt:10], [NSNumber numberWithInt:6]];
        } else if ([overlay isEqual:_walkingRouteToDestinationOverlay]){
            aRenderer.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.7];
            aRenderer.lineWidth = 4;
            aRenderer.lineDashPattern = @[[NSNumber numberWithInt:10], [NSNumber numberWithInt:6]];
        } else {
            return [super mapView:mapView viewForOverlay:overlay];
        }
        
        return aRenderer;
    }
    
    return nil;
}



@end
