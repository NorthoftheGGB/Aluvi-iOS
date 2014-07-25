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


#define kEditCommuteStatePickupTime 1000
#define kEditCommuteStateEditHome 1001
#define kEditCommuteStateEditWork 1002
#define kEditCommuteStateReturnTime 1003

@interface VCRideViewController () <MKMapViewDelegate, VCEditLocationWidgetDelegate, ActionSheetCustomPickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

// map
@property (strong, nonatomic) MKPointAnnotation * originAnnotation;
@property (strong, nonatomic) MKPointAnnotation * destinationAnnotation;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;

// data
@property (strong, nonatomic) NSArray * morningOptions;
@property (strong, nonatomic) NSArray * eveningOptions;

// outlets
@property (strong, nonatomic) IBOutlet UIView *homeActionView;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *editCommuteButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *rideNowButton;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *scheduleRideButton;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *nextButton;

//pickup hud
@property (strong, nonatomic) IBOutlet UIView *pickupHudView;
@property (weak, nonatomic) IBOutlet VCLabel *pickupTimeLabel;

//return hud
@property (strong, nonatomic) IBOutlet UIView *returnHudView;
@property (weak, nonatomic) IBOutlet VCLabel *returnTimeLabel;


@property (strong, nonatomic) VCEditLocationWidget * homeLocationWidget;
@property (strong, nonatomic) VCEditLocationWidget * workLocationWidget;

@property (nonatomic) BOOL appeared;
@property (nonatomic) NSInteger editCommuteState;

- (IBAction)didTapEditCommute:(id)sender;
- (IBAction)didTapRideNow:(id)sender;
- (IBAction)didTapScheduleRide:(id)sender;
- (IBAction)didTapNextButton:(id)sender;



@end

@implementation VCRideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _appeared = NO;
        
        _morningOptions = @[
                            @"6:00", @"6:30", @"7:00", @"7:30",
                            @"8:00", @"8:30", @"9:00", @"9:30",
                            @"10:00", @"10:30", @"11:00", @"11:30",
                            @"12:00"];
        _eveningOptions = @[
                            @"6:00", @"6:30", @"7:00", @"7:30",
                            @"8:00", @"8:30", @"9:00", @"9:30",
                            @"10:00", @"10:30", @"11:00", @"11:30",
                            @"12:00"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.title = @"Home";
    //custom image
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appcoda-logo.png"]];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancel:)];
    self.navigationItem.rightBarButtonItem = cancelItem;
    
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
        [self showHome];
        
        self.map = [[MKMapView alloc] initWithFrame:self.view.frame];
        self.map.delegate = self;
        [self.view insertSubview:self.map atIndex:0];
        self.map.showsUserLocation = YES;
        
        _appeared = YES;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.5; //user needs to press for half a second.
        [self.map addGestureRecognizer:lpgr];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) transitionToEditCommute {
    [_homeActionView removeFromSuperview];
    
    _editCommuteState = kEditCommuteStatePickupTime;
    CGRect frame = _pickupHudView.frame;
    frame.origin.x = 0;
    frame.origin.y = 62;
    frame.size.height = 0;
    _pickupHudView.frame = frame;
    [self.view addSubview:self.pickupHudView];
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _pickupHudView.frame;
        frame.size.height = 47;
        _pickupHudView.frame = frame;
    }];
    
    
    
    [ActionSheetStringPicker showPickerWithTitle: @"coco"
                                            rows: _morningOptions
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self transitionFromEditPickupTimeToEditHome];
                                       } cancelBlock:^(ActionSheetStringPicker *picker) {
                                           [self resetInterface];
                                       } origin:self.view];
    /*
     [ActionSheetCustomPicker showPickerWithTitle:@"Departure Time"
     delegate:self
     showCancelButton:YES
     origin:self.view];
     */
}

- (void) resetInterface {
    [UIView transitionWithView:self.view duration:.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_pickupHudView removeFromSuperview];
        [_homeLocationWidget.view removeFromSuperview];
        [_workLocationWidget.view removeFromSuperview];
        [self showHome];
    } completion:nil];
    
}

- (void) transitionFromEditPickupTimeToEditHome {
    
    _editCommuteState = kEditCommuteStateEditHome;
    
    _homeLocationWidget.mode = kEditLocationWidgetEditMode;
    CGRect frame = _homeLocationWidget.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 109;
    frame.size.height = 0;
    _homeLocationWidget.view.frame = frame;
    [self.view addSubview:_homeLocationWidget.view];
    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _homeLocationWidget.view.frame;
        frame.size.height = 47;
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
    frame.origin.y = 156;
    frame.size.height = 0;
    _workLocationWidget.view.frame = frame;
    [self.view addSubview:_workLocationWidget.view];
    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _workLocationWidget.view.frame;
        frame.size.height = 47;
        _workLocationWidget.view.frame = frame;
    }];
    
}

- (void) transitionFromEditWorkToSetReturnTime {
    [_nextButton removeFromSuperview];
    
    CGRect frame = _returnHudView.frame;
    frame.origin.x = 0;
    frame.origin.y = 203;
    frame.size.height = 0;
    _returnHudView.frame = frame;
    [self.view addSubview:self.returnHudView];
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _returnHudView.frame;
        frame.size.height = 47;
        _returnHudView.frame = frame;
    }];
    
    
    
    [ActionSheetStringPicker showPickerWithTitle: @"vococo"
                                            rows: _eveningOptions
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self transitionFromSetReturnTimeToScheduleRide];
                                       } cancelBlock:^(ActionSheetStringPicker *picker) {
                                           [self transitionFromSetReturnTimeToEditWork];
                                       } origin:self.view];
    
}

- (void) transitionFromSetReturnTimeToEditWork {
    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _returnHudView.frame;
        frame.size.height = 0;
        _returnHudView.frame = frame;
    } completion:^(BOOL finished) {
        [_returnHudView removeFromSuperview];
    } ];
    
    [self showNextButton];

}

- (void) transitionFromSetReturnTimeToScheduleRide {
    
    CGRect frame = _scheduleRideButton.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - 53;
    _scheduleRideButton.frame = frame;
    [self.view addSubview:_scheduleRideButton];
}


- (void) didTapCancel: (id)sender {
    [self resetInterface];
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
        CLLocation * origin = [[CLLocation alloc] initWithLatitude:_originAnnotation.coordinate.latitude longitude:_originAnnotation.coordinate.longitude];
        CLLocation * destination = [[CLLocation alloc] initWithLatitude:_destinationAnnotation.coordinate.latitude longitude:_destinationAnnotation.coordinate.longitude];
        [self showSuggestedRoute:origin to:destination];
    }
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude  longitude:touchMapCoordinate.longitude];
    [self updateEditLocationWidget:widget withLocation:location];
    [self showNextButton];
   
}

- (void) updateEditLocationWidget: (VCEditLocationWidget *) editLocationWidget withLocation: (CLLocation *) location {
    editLocationWidget.waiting = YES;
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        MKPlacemark * placemark = placemarks[0];
        [editLocationWidget setLocationText:  ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)];
        editLocationWidget.mode = kEditLocationWidgetDisplayMode;
        editLocationWidget.waiting = NO;
        
    }];
}

- (IBAction)didTapEditCommute:(id)sender {
    [self transitionToEditCommute];
    
}

- (IBAction)didTapRideNow:(id)sender {
}

- (IBAction)didTapScheduleRide:(id)sender {
    //TODO: API Call

}

- (IBAction)didTapNextButton:(id)sender {
    
    if( _editCommuteState == kEditCommuteStateEditHome) {
        [self transitionFromEditHomeToEditWork];
    } else {
        [self transitionFromEditWorkToSetReturnTime];
    }
    
}


#pragma mark - VCLocationSearchViewControllerDelegate
- (void) editLocationWidget:(VCEditLocationWidget *)widget didSelectMapItem:(MKMapItem *)mapItem {
    
    if(widget.type == kHomeType) {
    
        if(_originAnnotation != nil){
            [self.map removeAnnotation:_originAnnotation];
        }
        _originAnnotation = [[MKPointAnnotation alloc] init];
        _originAnnotation.coordinate = CLLocationCoordinate2DMake(mapItem.placemark.coordinate.latitude, mapItem.placemark.coordinate.longitude);
        _originAnnotation.title = @"Home";
        [self.map addAnnotation:_originAnnotation];
        widget.waiting = NO;
        
    } else if (widget.type == kWorkType) {
        
        if(_destinationAnnotation != nil){
            [self.map removeAnnotation:_destinationAnnotation];
        }
        _destinationAnnotation = [[MKPointAnnotation alloc] init];
        _destinationAnnotation.coordinate = CLLocationCoordinate2DMake(mapItem.placemark.coordinate.latitude, mapItem.placemark.coordinate.longitude);
        _destinationAnnotation.title = @"Work";
        [self.map addAnnotation:_destinationAnnotation];
        widget.waiting = NO;

    }
    
    [self showNextButton];

    [self.map setCenterCoordinate:mapItem.placemark.coordinate animated:YES];
}

// TODO: do something

#pragma mark - ActionSheetCustomPickerDelegate
- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView {
    pickerView.delegate = self;
    [pickerView setBackgroundColor:[UIColor clearColor]];
}

/*
 -(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
 
 }
 
 
 - (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
 
 }
 */

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
        
    }
}


@end
