//
//  VCRideViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRideViewController.h"
#import <MapKit/MapKit.h>
#import <ActionSheetPicker-3.0/ActionSheetStringPicker.h>
#import <ActionSheetCustomPicker.h>
@import AddressBookUI;
#import "VCLabel.h"
#import "VCButtonStandardStyle.h"
#import "VCEditLocationWidget.h"
#import "VCCommuteManager.h"
#import "VCRideDetailsView.h"
#import "VCRideDetailsConfirmationView.h"
#import "VCRideDetailsHudView.h"

#define kEditCommuteStatePickupTime 1000
#define kEditCommuteStateEditHome 1001
#define kEditCommuteStateEditWork 1002
#define kEditCommuteStateReturnTime 1003
#define kEditCommuteStateEditAll 1004

#define kStepSetDepartureLocation 1
#define kStepSetDestinationLocation 2
#define kStepConfirmRequest 3
#define kStepDone 4

#define kFareNotStartedLabelText @"Waiting"

@interface VCRideViewController () <MKMapViewDelegate, VCEditLocationWidgetDelegate, ActionSheetCustomPickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

// map
@property (strong, nonatomic) MKPointAnnotation * originAnnotation;
@property (strong, nonatomic) MKPointAnnotation * destinationAnnotation;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;

// data
@property (strong, nonatomic) NSArray * morningOptions;
@property (strong, nonatomic) NSArray * eveningOptions;


@property (strong, nonatomic) IBOutlet UIView *homeActionView;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *editCommuteButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *rideNowButton;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *nextButton;

//confirmation
@property (strong, nonatomic) IBOutlet UIView *hovDriverOptionView;
@property (weak, nonatomic) IBOutlet UIButton *hovDriveYesButton;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *scheduleRideButton;

//pickup hud
@property (strong, nonatomic) IBOutlet UIView *pickupHudView;
@property (weak, nonatomic) IBOutlet VCLabel *pickupTimeLabel;
- (IBAction)didTapPickupHud:(id)sender;

//return hud
@property (strong, nonatomic) IBOutlet UIView *returnHudView;
@property (weak, nonatomic) IBOutlet VCLabel *returnTimeLabel;
- (IBAction)didTapReturnHud:(id)sender;

//overlay
@property (strong, nonatomic) IBOutlet UIView *waitingScreen;
@property (strong, nonatomic) IBOutlet VCRideDetailsConfirmationView *rideDetailsConfirmation;
@property (strong, nonatomic) IBOutlet VCRideDetailsHudView *rideDetailsHud;

// Data Entry
@property (nonatomic) NSInteger step;


@property (strong, nonatomic) VCEditLocationWidget * homeLocationWidget;
@property (strong, nonatomic) VCEditLocationWidget * workLocationWidget;

//RIDE DETAILS CONFIRMATION SCREEN



@property (nonatomic) BOOL appeared;
@property (nonatomic) NSInteger editCommuteState;

- (IBAction)didTapEditCommute:(id)sender;
- (IBAction)didTapRideNow:(id)sender;
- (IBAction)didTapScheduleRide:(id)sender;
- (IBAction)didTapNextButton:(id)sender;
- (IBAction)didTapHovDriveYesButton:(id)sender;



@end

@implementation VCRideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _appeared = NO;
        
        _morningOptions = @[ @"Select Pickup Time",
                             @"6:00", @"6:30", @"7:00", @"7:30",
                             @"8:00", @"8:30", @"9:00", @"9:30",
                             @"10:00", @"10:30", @"11:00", @"11:30",
                             @"12:00"];
        _eveningOptions = @[ @"Select Return Time",
                             @"6:00", @"6:30", @"7:00", @"7:30",
                             @"8:00", @"8:30", @"9:00", @"9:30",
                             @"10:00", @"10:30", @"11:00", @"11:30",
                             @"12:00"];
        
        _step = kStepSetDepartureLocation;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.title = @"Home";
    //custom image
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appcoda-logo.png"]];
    
    _homeLocationWidget = [[VCEditLocationWidget alloc] init];
    _homeLocationWidget.delegate = self;
    _workLocationWidget = [[VCEditLocationWidget alloc] init];
    _workLocationWidget.delegate = self;
    _homeLocationWidget.type = kHomeType;
    _workLocationWidget.type = kWorkType;
    [self addChildViewController:_homeLocationWidget];
    [self addChildViewController:_workLocationWidget];
    
    
    
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if(!_appeared){
        
        self.map = [[MKMapView alloc] initWithFrame:self.view.frame];
        self.map.delegate = self;
        [self.view insertSubview:self.map atIndex:0];
        self.map.showsUserLocation = YES;
        
        _appeared = YES;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.5; //user needs to press for half a second.
        [self.map addGestureRecognizer:lpgr];
        
        if(_ride == nil) {
            [self showHome];
            self.map.userTrackingMode = MKUserTrackingModeFollow;
        } else {
            [self showInterfaceForRide];
        }
    }

 

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setRequest:(Ride *)ride {
    _ride = ride;
    self.transit = ride;
}

- (void) showHome{
    
    CGRect frame = _homeActionView.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - 53;
    _homeActionView.frame = frame;
    [self.view addSubview:self.homeActionView];
    
    CGRect currentLocationframe = _currentLocationButton.frame;
    currentLocationframe.origin.x = 276;
    currentLocationframe.origin.y = self.view.frame.size.height - 101;
    _currentLocationButton.frame = currentLocationframe;
    [self.view addSubview:self.currentLocationButton];
    
    
}

- (void) showInterfaceForRide {
    [_homeActionView removeFromSuperview];
    [self showCancelBarButton];
    
    [self addOriginAnnotation: [_ride originLocation] ];
    [self addDestinationAnnotation: [_ride destinationLocation]];
    [self showSuggestedRoute: [_ride originLocation] to:[_ride destinationLocation]];
    if([@[kCreatedState, kRequestedState] containsObject:_ride.state]){
        [self.view addSubview:self.waitingScreen];
    } else if([_ride.confirmed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [self.view addSubview:_rideDetailsHud];
    } else {
        [self.view addSubview:_rideDetailsConfirmation];
    }
    
}

- (void) showCancelBarButton {
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancel:)];
    self.navigationItem.rightBarButtonItem = cancelItem;
}

- (void) removeCancelBarButton {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) transitionToEditCommute {
    [_homeActionView removeFromSuperview];
    _editCommuteState = kEditCommuteStateEditAll;
    
    [self showCancelBarButton];
    
    {
        CGRect frame = _pickupHudView.frame;
        frame.origin.x = 0;
        frame.origin.y = 62;
        frame.size.height = 0;
        _pickupHudView.frame = frame;
        [self.view addSubview:self.pickupHudView];
    }
    {
        _homeLocationWidget.mode = kEditLocationWidgetEditMode;
        CGRect frame = _homeLocationWidget.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 102;
        frame.size.height = 0;
        _homeLocationWidget.view.frame = frame;
        _homeLocationWidget.mode = kEditLocationWidgetDisplayMode;
        [self.view addSubview:_homeLocationWidget.view];
    }
    {
        _workLocationWidget.mode = kEditLocationWidgetEditMode;
        CGRect frame = _homeLocationWidget.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 142;
        frame.size.height = 0;
        _workLocationWidget.view.frame = frame;
        _workLocationWidget.mode = kEditLocationWidgetDisplayMode;
        [self.view addSubview:_workLocationWidget.view];
    }
    {
        CGRect frame = _returnHudView.frame;
        frame.origin.x = 0;
        frame.origin.y = 182;
        frame.size.height = 0;
        _returnHudView.frame = frame;
        [self.view addSubview:self.returnHudView];
    }
    {
        CGRect frame = _hovDriverOptionView.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.frame.size.height - 91;
        _hovDriverOptionView.frame = frame;
        [self.view addSubview:_hovDriverOptionView];
    }
    {
        CGRect frame = _scheduleRideButton.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.frame.size.height - 53;
        _scheduleRideButton.frame = frame;
        [self.view addSubview:_scheduleRideButton];
    }

    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _pickupHudView.frame;
        frame.size.height = 40; //changed height
        _pickupHudView.frame = frame;
        
        frame = _homeLocationWidget.view.frame;
        frame.size.height = 40;
        _homeLocationWidget.view.frame = frame;
        
        frame = _workLocationWidget.view.frame;
        frame.size.height = 40;
        _workLocationWidget.view.frame = frame;
        
        frame = _returnHudView.frame;
        frame.size.height = 40;
        _returnHudView.frame = frame;
        
    }];
    
}

- (void) transitionToSetupCommute {
    [_homeActionView removeFromSuperview];
    [self showCancelBarButton];
    
    _editCommuteState = kEditCommuteStatePickupTime;
    CGRect frame = _pickupHudView.frame;
    frame.origin.x = 0;
    frame.origin.y = 62;
    frame.size.height = 0;
    _pickupHudView.frame = frame;
    [self.view addSubview:self.pickupHudView];
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _pickupHudView.frame;
        frame.size.height = 40; //changed height
        _pickupHudView.frame = frame;
    }];
    
    [self showPickupTimePicker];
    
}

- (void) resetInterface {
    [self clearMap];
    [UIView transitionWithView:self.view duration:.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_waitingScreen removeFromSuperview];
        [_pickupHudView removeFromSuperview];
        [_homeLocationWidget.view removeFromSuperview];
        [_workLocationWidget.view removeFromSuperview];
        [_returnHudView removeFromSuperview];
        [_scheduleRideButton removeFromSuperview];
        [_hovDriverOptionView removeFromSuperview];
        [_nextButton removeFromSuperview];
        [self removeCancelBarButton];
        [self showHome];
    } completion:^(BOOL finished) {
        [self zoomToCurrentLocation];
    }];
    
}

- (void) clearMap {
    [super clearMap];
    [self.map removeAnnotation:_originAnnotation];
    [self.map removeAnnotation:_destinationAnnotation];
}

- (void) transitionFromEditPickupTimeToEditHome {
    
    _editCommuteState = kEditCommuteStateEditHome;
    
    _homeLocationWidget.mode = kEditLocationWidgetEditMode;
    CGRect frame = _homeLocationWidget.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 102;
    frame.size.height = 0;
    _homeLocationWidget.view.frame = frame;
    [self.view addSubview:_homeLocationWidget.view];
    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _homeLocationWidget.view.frame;
        frame.size.height = 40;
        _homeLocationWidget.view.frame = frame;
    }];
    
    
}

- (void) showNextButton {
    
    if(_nextButton.superview == nil) {
        CGRect buttonFrame = _nextButton.frame;
        buttonFrame.origin.x = 0;
        buttonFrame.origin.y = self.view.frame.size.height - 53;
        _nextButton.frame = buttonFrame;
        [self.view addSubview:_nextButton];
    }
}

- (void) transitionFromEditHomeToEditWork {
    
    _editCommuteState = kEditCommuteStateEditWork;
    
    [_nextButton removeFromSuperview];
    
    _workLocationWidget.mode = kEditLocationWidgetEditMode;
    CGRect frame = _homeLocationWidget.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 142;
    frame.size.height = 0;
    _workLocationWidget.view.frame = frame;
    [self.view addSubview:_workLocationWidget.view];
    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _workLocationWidget.view.frame;
        frame.size.height = 40;
        _workLocationWidget.view.frame = frame;
    }];
    
}

- (void) transitionFromEditWorkToSetReturnTime {
    
    _editCommuteState = kEditCommuteStateReturnTime;
    
    [_nextButton removeFromSuperview];
    
    CGRect frame = _returnHudView.frame;
    frame.origin.x = 0;
    frame.origin.y = 182;
    frame.size.height = 0;
    _returnHudView.frame = frame;
    [self.view addSubview:self.returnHudView];
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _returnHudView.frame;
        frame.size.height = 40;
        _returnHudView.frame = frame;
    }];
    
    [self showReturnTimePicker];
    
}

- (void) showReturnTimePicker {
    [ActionSheetCustomPicker showPickerWithTitle:@"Return Time"
                                        delegate:self
                                showCancelButton:YES
                                          origin:self.view ];
}

- (void) showPickupTimePicker {
    [ActionSheetCustomPicker showPickerWithTitle:@"Pickup Time"
                                        delegate:self
                                showCancelButton:YES
                                          origin:self.view ];
}

- (void) transitionFromSetReturnTimeToEditWork {
    
    _editCommuteState = kEditCommuteStateEditWork;
    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _returnHudView.frame;
        frame.size.height = 0;
        _returnHudView.frame = frame;
    } completion:^(BOOL finished) {
        [_returnHudView removeFromSuperview];
    } ];
    
    [self showNextButton];
    [_scheduleRideButton removeFromSuperview];
    
    
}

- (void) transitionFromSetReturnTimeToScheduleRide {
    
    [_currentLocationButton removeFromSuperview];
    
    CGRect frame = _hovDriverOptionView.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - 91;
    _hovDriverOptionView.frame = frame;
    [self.view addSubview:_hovDriverOptionView];
    
    
    {CGRect frame = _scheduleRideButton.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.frame.size.height - 53;
        _scheduleRideButton.frame = frame;
        [self.view addSubview:_scheduleRideButton];}
}

- (void) transitionToWaitingScreen {
    //TODO improve animations
    [_scheduleRideButton removeFromSuperview];
    [self.view addSubview:self.waitingScreen];
}


- (void) didTapCancel: (id)sender {
    if(_ride == nil) {
        [[VCCommuteManager instance] reset];
        [self resetInterface];
    } else {
        [UIAlertView showWithTitle:@"Cancel Ride?" message:@"Are you sure you want to cancel this ride?" cancelButtonTitle:@"No!" otherButtonTitles:@[@"Yes, Cancel this ride"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch(buttonIndex){
                case 1:
                {
                    [[VCCommuteManager instance] cancelRide:_ride success:^{
                        [self resetInterface];
                    } failure:^{
                        // do nothing
                    }];
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    MKPointAnnotation * annotation;
    VCEditLocationWidget * widget;
    
    if(_editCommuteState == kEditCommuteStateEditHome) {
        annotation = _originAnnotation;
        widget = _homeLocationWidget;
    } else if (_editCommuteState == kEditCommuteStateEditWork) {
        annotation = _destinationAnnotation;
        widget = _workLocationWidget;
    } else {
        return;
    }
    
    if( annotation != nil ){
        [self.map removeAnnotation:annotation];
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.map];
    CLLocationCoordinate2D touchMapCoordinate = [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
    annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = touchMapCoordinate;
    [self.map addAnnotation:annotation];
    
    if(_editCommuteState == kEditCommuteStateEditHome) {
        _originAnnotation = annotation;
    } else if (_editCommuteState == kEditCommuteStateEditWork) {
        _destinationAnnotation = annotation;
    }
    [self updateRouteOverlay];
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude  longitude:touchMapCoordinate.longitude];
    [self updateEditLocationWidget:widget withLocation:location];
    [self showNextButton];
    
}

- (void) updateEditLocationWidget: (VCEditLocationWidget *) editLocationWidget
                     withLocation: (CLLocation *) location {
    editLocationWidget.waiting = YES;
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        MKPlacemark * placemark = placemarks[0];
        [editLocationWidget setLocationText:  ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)];
        editLocationWidget.mode = kEditLocationWidgetDisplayMode;
        editLocationWidget.waiting = NO;
        
    }];
}

- (void) storeCommuterSettings {
    [VCCommuteManager instance].home = [[CLLocation alloc] initWithLatitude:_originAnnotation.coordinate.latitude
                                                                             longitude:_originAnnotation.coordinate.longitude];
    [VCCommuteManager instance].work = [[CLLocation alloc] initWithLatitude:_destinationAnnotation.coordinate.latitude
                                                                                  longitude:_destinationAnnotation.coordinate.longitude];
    
    
    [[VCCommuteManager instance] save];
    
    
}

- (void) loadCommuteSettings {
    if( [VCCommuteManager instance].pickupTime != nil){
        _pickupTimeLabel.text = [VCCommuteManager instance].pickupTime;
    }
    
    if( [VCCommuteManager instance].home != nil){
        [self addOriginAnnotation: [VCCommuteManager instance].home ];
        [self updateEditLocationWidget:_homeLocationWidget withLocation:[VCCommuteManager instance].home];
    }
    
    if( [VCCommuteManager instance].work != nil){
        [self addDestinationAnnotation: [VCCommuteManager instance].work ];
        [self updateEditLocationWidget:_workLocationWidget withLocation:[VCCommuteManager instance].work];
    }
    
    if( [VCCommuteManager instance].returnTime != nil){
        _returnTimeLabel.text = [VCCommuteManager instance].returnTime;
    }
    
    _hovDriveYesButton.selected = [VCCommuteManager instance].driving;
    
    if( [VCCommuteManager instance].home != nil && [VCCommuteManager instance].home != nil){
        [self showSuggestedRoute: [VCCommuteManager instance].home to:[VCCommuteManager instance].work];
    }
    
}

// Annotations
- (void)addOriginAnnotation:(CLLocation *)location {
    if(_originAnnotation != nil){
        [self.map removeAnnotation:_originAnnotation];
    }
    _originAnnotation = [[MKPointAnnotation alloc] init];
    _originAnnotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    _originAnnotation.title = @"Home";
    [self.map addAnnotation:_originAnnotation];
}

- (void)addDestinationAnnotation:(CLLocation *)location {
    if(_destinationAnnotation != nil){
        [self.map removeAnnotation:_destinationAnnotation];
    }
    _destinationAnnotation = [[MKPointAnnotation alloc] init];
    _destinationAnnotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    _destinationAnnotation.title = @"Home";
    [self.map addAnnotation:_destinationAnnotation];
}

- (IBAction)didTapEditCommute:(id)sender {
    [self loadCommuteSettings];
    
    if([[VCCommuteManager instance] hasSettings]) {
        [self transitionToEditCommute];
    } else {
        [self transitionToSetupCommute];
    }
}

- (IBAction)didTapRideNow:(id)sender {
}

- (IBAction)didTapScheduleRide:(id)sender {
    [self storeCommuterSettings];
    
    [UIAlertView showWithTitle:@"Schedule Commuter Ride ?" message:@"Do you want us to schedule your commuter ride for tomorrow?" cancelButtonTitle:@"No, not I won't be commuting tomorrow" otherButtonTitles:@[@"Yes!  I want to ride with Voco tomorrow!"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 1:
            {
                [self transitionToWaitingScreen];
                
                // Create tomorrows rides
                NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                dayComponent.day = 1;
                
                NSCalendar *theCalendar = [NSCalendar currentCalendar];
                NSDate *tomorrow = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];

                [[VCCommuteManager instance] requestRidesFor:tomorrow];
            }
                break;
                
            default:
                [self resetInterface]; // TOOD: transition to home ?
                break;
        }
    }];
}

- (IBAction)didTapNextButton:(id)sender {
    
    if( _editCommuteState == kEditCommuteStateEditHome) {
        [self transitionFromEditHomeToEditWork];
    } else {
        [self transitionFromEditWorkToSetReturnTime];
    }
    
}

- (IBAction)didTapHovDriveYesButton:(id)sender {
    
    if (_hovDriveYesButton.selected == YES){
        _hovDriveYesButton.selected = NO;
        [VCCommuteManager instance].driving = NO;
    } else {
        _hovDriveYesButton.selected = YES;
        [VCCommuteManager instance].driving = YES;
    }
}

- (IBAction)didTapPickupHud:(id)sender {
    [self showPickupTimePicker];
}


- (IBAction)didTapReturnHud:(id)sender {
    [self showReturnTimePicker];
}


#pragma mark - VCLocationSearchViewControllerDelegate

- (void) editLocationWidget:(VCEditLocationWidget *)widget didSelectMapItem:(MKMapItem *)mapItem {
    
    if(widget.type == kHomeType) {
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:mapItem.placemark.coordinate.latitude longitude:mapItem.placemark.coordinate.longitude];
        [self addOriginAnnotation:location];
        widget.waiting = NO;
        
        
    } else if (widget.type == kWorkType) {
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:mapItem.placemark.coordinate.latitude longitude:mapItem.placemark.coordinate.longitude];
        [self addDestinationAnnotation:location];
        widget.waiting = NO;
        
    }
    
    [self updateRouteOverlay];
    
    if(_editCommuteState == kEditCommuteStateEditHome || _editCommuteState == kEditCommuteStateEditWork) {
        [self showNextButton];
    }
    
    [self.map setCenterCoordinate:mapItem.placemark.coordinate animated:YES];
}

- (void) updateRouteOverlay {
    
    if(_originAnnotation != nil && _destinationAnnotation != nil){
        [self clearRoute];
        // if locations change
        CLLocation * origin = [[CLLocation alloc] initWithLatitude:_originAnnotation.coordinate.latitude
                                                         longitude:_originAnnotation.coordinate.longitude];
        CLLocation * destination = [[CLLocation alloc] initWithLatitude:_destinationAnnotation.coordinate.latitude
                                                              longitude:_destinationAnnotation.coordinate.longitude];
        [self showSuggestedRoute:origin to:destination];
    }
    
}

// TODO: do something

#pragma mark - ActionSheetCustomPickerDelegate
- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView {
    pickerView.delegate = self;
    [pickerView setBackgroundColor:[UIColor clearColor]];
    [pickerView setAlpha:.95];
    
    [actionSheetPicker.toolbar setAlpha:.95];
    [actionSheetPicker.toolbar setBackgroundColor:[UIColor clearColor]];
}

- (void) actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    if( _editCommuteState == kEditCommuteStateReturnTime) {
        [self transitionFromSetReturnTimeToScheduleRide];
    } else if ( _editCommuteState == kEditCommuteStatePickupTime) {
        [self transitionFromEditPickupTimeToEditHome];
    }
}

- (void) actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    if( _editCommuteState == kEditCommuteStateReturnTime) {
        [self transitionFromSetReturnTimeToEditWork];
    } else if ( _editCommuteState == kEditCommuteStatePickupTime) {
        [self resetInterface];
    }
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if( _editCommuteState == kEditCommuteStateReturnTime) {
        return [_eveningOptions count];
    } else if ( _editCommuteState == kEditCommuteStatePickupTime) {
        return [_morningOptions count];
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if( _editCommuteState == kEditCommuteStateReturnTime) {
        return [_eveningOptions objectAtIndex:row];
    } else if ( _editCommuteState == kEditCommuteStatePickupTime) {
        return [_morningOptions objectAtIndex:row];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString * value = [_morningOptions objectAtIndex:row];
    if( _editCommuteState == kEditCommuteStateReturnTime) {
        [VCCommuteManager instance].returnTime = value;
        _returnTimeLabel.text = value;
    } else if ( _editCommuteState == kEditCommuteStatePickupTime) {
        [VCCommuteManager instance].pickupTime = value;
        _pickupTimeLabel.text = value;
    }
}


#pragma mark - MapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isEqual: _originAnnotation] || [annotation isEqual:_destinationAnnotation]) {
        MKPinAnnotationView * pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PIN_ANNOTATION"];
        pinAnnotationView.animatesDrop = YES;
        pinAnnotationView.pinColor = MKPinAnnotationColorRed;
        pinAnnotationView.draggable = YES;
        return pinAnnotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    if( oldState == MKAnnotationViewDragStateDragging && newState == MKAnnotationViewDragStateEnding) {
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:annotationView.annotation.coordinate.latitude
                                                           longitude:annotationView.annotation.coordinate.longitude];
        
        if([annotationView.annotation isEqual: _originAnnotation]) {
            [self updateEditLocationWidget:_homeLocationWidget withLocation:location];
        } else if ( [annotationView.annotation isEqual: _destinationAnnotation]) {
            [self updateEditLocationWidget:_workLocationWidget withLocation:location];
        }
        [self clearRoute];
        [self updateRouteOverlay];
        
    }
}


@end
