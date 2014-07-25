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

@interface VCRideViewController () <MKMapViewDelegate, VCEditLocationWidgetDelegate, ActionSheetCustomPickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

// map
@property (strong, nonatomic) MKPointAnnotation * originAnnotation;
@property (strong, nonatomic) MKPointAnnotation * destinationAnnotation;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;

// data
@property (strong, nonatomic) NSArray * morningOptions;

// outlets
@property (strong, nonatomic) IBOutlet UIView *homeActionView;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *editCommuteButton;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *rideNowButton;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *scheduleRideButton;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *nextButton;

@property (strong, nonatomic) IBOutlet UIView *rideInfoItemView;
@property (weak, nonatomic) IBOutlet VCLabel *itemNameLabel;
@property (strong, nonatomic) IBOutlet UIView *itemValueLabel;

@property (strong, nonatomic) VCEditLocationWidget * homeLocationWidget;
@property (strong, nonatomic) VCEditLocationWidget * workLocationWidget;

@property (nonatomic) BOOL appeared;

- (IBAction)didTapEditCommute:(id)sender;
- (IBAction)didTapRideNow:(id)sender;
- (IBAction)didTapScheduleRide:(id)sender;
- (IBAction)didTapCurrentLocation:(id)sender;
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

- (void) moveToEditCommute {
    [_homeActionView removeFromSuperview];
    
    CGRect frame = _rideInfoItemView.frame;
    frame.origin.x = 0;
    frame.origin.y = 62;
    frame.size.height = 0;
    _rideInfoItemView.frame = frame;
    [self.view addSubview:self.rideInfoItemView];
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _rideInfoItemView.frame;
        frame.size.height = 47;
        _rideInfoItemView.frame = frame;
    }];
    
    
    
    [ActionSheetStringPicker showPickerWithTitle: @"coco"
                                            rows: _morningOptions
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self editHome];
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
        [_rideInfoItemView removeFromSuperview];
        [_homeLocationWidget.view removeFromSuperview];
        [_workLocationWidget.view removeFromSuperview];
        [self showHome];
    } completion:nil];
    
}

- (void) editHome {
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
    
    CGRect buttonFrame = _nextButton.frame;
    buttonFrame.origin.x = 0;
    buttonFrame.origin.y = self.view.frame.size.height - 53;
    _nextButton.frame = buttonFrame;
    [self.view addSubview:_nextButton];
    
}

- (void) transitionFromEditHomeToEditWork {
    // TODO: [_nextButton removeFromSuperview];
    
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



- (void) didTapCancel: (id)sender {
    [self resetInterface];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if( _originAnnotation != nil ){
        [self.map removeAnnotation:_originAnnotation];
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.map];
    CLLocationCoordinate2D touchMapCoordinate = [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
    _originAnnotation = [[MKPointAnnotation alloc] init];
    _originAnnotation.coordinate = touchMapCoordinate;
    [self.map addAnnotation:_originAnnotation];
    
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude  longitude:touchMapCoordinate.longitude];
    [self updateEditLocationWidget:_homeLocationWidget withLocation:location];
    
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
    [self moveToEditCommute];
    
}

- (IBAction)didTapRideNow:(id)sender {
}

- (IBAction)didTapScheduleRide:(id)sender {
}

- (IBAction)didTapNextButton:(id)sender {
    [self transitionFromEditHomeToEditWork];
    
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
    if(annotation == _originAnnotation) {
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
