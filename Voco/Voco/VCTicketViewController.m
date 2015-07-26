//
//  VCRideViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTicketViewController.h"
@import AddressBookUI;
#import <MapKit/MapKit.h>
#import <MBProgressHUD.h>
#import <ActionSheetPicker-3.0/ActionSheetStringPicker.h>
#import <ActionSheetCustomPicker.h>
#import "IIViewDeckController.h"
#import <MBXMapKit/MBXMapKit.h>

#import "VCNotifications.h"
#import "VCInterfaceManager.h"

#import "VCDriverApi.h"
#import "VCPushApi.h"

#import "Driver.h"
#import "Car.h"

#import "VCLabel.h"
#import "VCButtonStandardStyle.h"
#import "VCEditLocationWidget.h"
#import "VCCommuteManager.h"
#import "VCAbstractRideDetailsView.h"
#import "VCRideDetailsView.h"
#import "VCRideOverviewHudView.h"
#import "NSDate+Pretty.h"
#import "VCUserStateManager.h"
#import "VCDriveViewController.h"
#import "VCMapQuestRouting.h"
#import "VCButton.h"
#import "IIViewDeckController.h"
#import "VCDriveDetailsView.h"
#import "VCDriverCallHudView.h"
#import "VCFare.h"
#import "VCUtilities.h"
#import "VCHoldingView.h"

#define kEditCommuteStatePickupTime 1000
#define kEditCommuteStateEditHome 1001
#define kEditCommuteStateEditWork 1002
#define kEditCommuteStateReturnTime 1003
#define kEditCommuteStateEditAll 1004

#define kStepNone 0
#define kStepSetDepartureLocation 1
#define kStepSetDestinationLocation 2
#define kStepConfirmRequest 3
#define kStepDone 4

#define kPickerReturnTime 1
#define kPickerPickupTime 2

#define kFareNotStartedLabelText @"Waiting"

#define kDriverCallHudOriginX 271
#define kDriverCallHudOriginY 226
#define kDriverCallHudOpenX 31
#define kDriverCallHudOpenY 226

#define kDriverCancelHudOriginX 271
#define kDriverCancelHudOriginY 302
#define kDriverCancelHudOpenX 165
#define kDriverCancelHudOpenY 302

@interface VCTicketViewController () <MKMapViewDelegate, VCEditLocationWidgetDelegate, ActionSheetCustomPickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, MBXRasterTileOverlayDelegate>


// map
@property (strong, nonatomic) MKPointAnnotation * originAnnotation;
@property (strong, nonatomic) MKPointAnnotation * destinationAnnotation;
@property (strong, nonatomic) MKPointAnnotation * meetingPointAnnotation;
@property (strong, nonatomic) MKPointAnnotation * dropOffPointAnnotation;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) MBXRasterTileOverlay * tileOverlay;

// data
@property (strong, nonatomic) NSArray * morningOptions;
@property (strong, nonatomic) NSArray * eveningOptions;

@property (strong, nonatomic) IBOutlet UIView *homeActionView;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *editCommuteButton;
@property (strong, nonatomic) IBOutlet VCButtonStandardStyle *rideNowButton;
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

//Holding Screen / Confirmation Screen
@property (strong, nonatomic) IBOutlet VCHoldingView *holdingScreen;


@property (weak, nonatomic) Ticket * showingTicket;
- (IBAction)didTapOKButton:(id)sender;

//Ride Details
@property (strong, nonatomic) IBOutlet VCRideDetailsView * rideItineraryView;
@property (strong, nonatomic) UIScrollView * scrollView;
- (IBAction)didChangeDisplayDirectionValue:(id)sender;

//RideOverview
@property (strong, nonatomic) IBOutlet VCRideOverviewHudView *rideDetailsHud;

// Data Entry
@property (nonatomic) NSInteger step;
@property (nonatomic) NSInteger whichPicker;


@property (strong, nonatomic) VCEditLocationWidget * homeLocationWidget;
@property (strong, nonatomic) VCEditLocationWidget * workLocationWidget;

@property (nonatomic) BOOL appeared;
@property (nonatomic) NSInteger editCommuteState;

- (IBAction)didTapEditCommute:(id)sender;
- (IBAction)didTapRideNow:(id)sender;
- (IBAction)didTapScheduleRide:(id)sender;
- (IBAction)didTapNextButton:(id)sender;
- (IBAction)didTapHovDriveYesButton:(id)sender;
- (IBAction)didTapShowRideDetailsButton:(id)sender;


// HOV Driver
@property (strong, nonatomic) IBOutlet VCDriverCallHudView *driverCallHUD;
@property (strong, nonatomic) IBOutlet UIView *driverCancelHUD;
@property (strong, nonatomic) IBOutlet UIButton *directionsListButton;
@property (strong, nonatomic) IBOutlet VCDriveDetailsView * fareDetailsView;

//Call HUD
@property (nonatomic) BOOL callHudPanLocked;
@property (strong, nonatomic) NSTimer * timer;
@property (nonatomic) BOOL callHudOpen;
- (IBAction)didTapCallRider1:(id)sender;
- (IBAction)didTapCallRider2:(id)sender;
- (IBAction)didTapCallRider3:(id)sender;

//Cancel HUD
@property (nonatomic) BOOL cancelHudPanLocked;
@property (strong, nonatomic) NSTimer * cancelTimer;
@property (nonatomic) BOOL cancelHudOpen;
@property (strong, nonatomic) IBOutlet VCButton *cancelRideButton;
@property (strong, nonatomic) IBOutlet UIImageView *cancelIconImageView;
- (IBAction)didTapCancelRide:(id)sender;


//Ride Status
@property (strong, nonatomic) IBOutlet VCButton *ridersPickedUpButton;
@property (strong, nonatomic) IBOutlet VCButton *rideCompleteButton;
- (IBAction)didTapRidersPickedUp:(id)sender;
- (IBAction)didTapRideCompleted:(id)sender;

@end

@implementation VCTicketViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _appeared = NO;
        
        _morningOptions = @[ @"Select Pickup Time",
                             @"7:00", @"7:15", @"7:30", @"7:45",
                             @"8:00", @"8:25", @"8:30", @"8:45", @"9:00"
                             ];
        _eveningOptions = @[ @"Select Return Time",
                             @"4:00", @"4:15", @"4:30", @"4:45",
                             @"5:00", @"5:15", @"5:30", @"5:45",
                             @"6:00", @"6:15", @"6:30", @"6:45",
                             @"7:00"];
        
        _ticket = nil;
        
        _callHudPanLocked = NO;
        _callHudOpen = NO;
        _appeared = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startLocationUpdates];
    
    _homeLocationWidget = [[VCEditLocationWidget alloc] init];
    _homeLocationWidget.delegate = self;
    _workLocationWidget = [[VCEditLocationWidget alloc] init];
    _workLocationWidget.delegate = self;
    _homeLocationWidget.type = kHomeType;
    _workLocationWidget.type = kWorkType;
    [self addChildViewController:_homeLocationWidget];
    [self addChildViewController:_workLocationWidget];
    
    
    // Look for pending ticket
    if(_ticket == nil) {
        
        // Check for existing commuter ticket that is has not been processed
        NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"state IN %@  AND direction = 'a' AND confirmed = false \
                                   AND pickupTime > %@",
                                   @[kCreatedState, kRequestedState, kCommuteSchedulerFailedState],
                                   [VCUtilities beginningOfToday] ];
        [fetch setPredicate:predicate];
        NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"pickupTime" ascending:YES];
        [fetch setSortDescriptors:@[sort]];
        NSError * error;
        NSArray * tickets = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
        if(tickets == nil) {
            [WRUtilities criticalError:error];
        } else if([tickets count] > 0) {
            _ticket = [tickets objectAtIndex:0];
        }
    }
    // Look for next ticket for today/tomorrow
    if(_ticket == nil) {
        NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"state = 'scheduled' AND pickupTime > %@",
                                   [VCUtilities beginningOfToday] ];
        [fetch setPredicate:predicate];
        NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"pickupTime" ascending:YES];
        [fetch setSortDescriptors:@[sort]];
        NSError * error;
        NSArray * tickets = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
        if(tickets == nil) {
            [WRUtilities criticalError:error];
        } else if([tickets count] > 0) {
            _ticket = [tickets objectAtIndex:0];
        }
    }
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if(!_appeared){
        
        self.map = [[MKMapView alloc] initWithFrame:self.view.frame];
        self.map.delegate = self;
        [self.view insertSubview:self.map atIndex:0];
        self.map.showsUserLocation = YES;
        
        /*
         Skip the MapBox overlay for now, iPhone 4 rendering issues
         
        _tileOverlay = [[MBXRasterTileOverlay alloc] initWithMapID:@"aluvi.jlandbj7"];
        _tileOverlay.delegate = self;
        [self.map addOverlay:_tileOverlay];
        */
         
        _appeared = YES;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.5; //user needs to press for half a second.
        [self.map addGestureRecognizer:lpgr];
        
        if(_ticket == nil) {
            
            if([[VCCommuteManager instance] hasSettings]) {
                // if commute IS set up already
                [self showHome];
                self.map.userTrackingMode = MKUserTrackingModeFollow;
                
                [self addOriginAnnotation: [VCCommuteManager instance].home];
                [self addDestinationAnnotation: [VCCommuteManager instance].work];
                [self showSuggestedRoute: [VCCommuteManager instance].home to:[VCCommuteManager instance].work];
                
                
            } else {
                // if commute is not set up
                _step = kStepSetDepartureLocation;
                [self transitionToSetupCommute];
            }
            
            
        } else {
            [self showInterfaceForTicket];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripFulfilled:) name:kNotificationTypeTripFulfilled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripUnfulfilled:) name:kNotificationTypeTripUnfulfilled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareCompleted:) name:kNotificationTypeFareComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareCancelledByDriver:) name:kPushTypeFareCancelledByDriver object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareCancelledByRider:) name:kPushTypeFareCancelledByRider object:nil];

}

- (void) viewWillDisppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) tripFulfilled:(NSNotification *) notification {
    [self showInterfaceForPayload:notification.object];
}

- (void) tripUnfulfilled:(NSNotification *) notification {
    [self showInterfaceForPayload:notification.object];
    
}

- (void) showInterfaceForPayload:(NSDictionary *)payload {
    NSLog(@"%@", [payload debugDescription]);
    NSNumber * tripId = [payload objectForKey:VC_PUSH_TRIP_ID_KEY];
    if(_ticket == nil || [_ticket.trip_id isEqualToNumber:tripId]) {
        NSArray * ticketsForTrip = [Ticket ticketsForTrip:tripId];
        _ticket = [ticketsForTrip objectAtIndex:0];
        if(_ticket == nil){
            [WRUtilities criticalErrorWithString:@"Missing ticket for trip."];
            return;
        }
        [self showInterfaceForTicket];
    } else {
        // some debugging
        if(_ticket == nil){
            NSLog(@"Nil ticket");
        } else {
            NSLog(@"Viewing a different ticket %@", [_ticket debugDescription]);
        }
    }
    
}


- (void) fareCompleted:(NSNotification *) notification {
    NSDictionary * payload = notification.object;
    NSNumber * fareId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
    if(_ticket != nil && [fareId isEqualToNumber:_ticket.fare_id]){
        [self resetInterfaceToHome];
    }
    _ticket = nil;
}

- (void) fareCancelledByDriver:(NSNotification *) notification {
    NSDictionary * payload = notification.object;
    NSNumber * fareId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
    if(_ticket != nil && [fareId isEqualToNumber:_ticket.fare_id]){
        [self resetInterfaceToHome];
    }
    _ticket = nil;
}

- (void) fareCancelledByRider: (NSNotification *) notification {
    NSDictionary * payload = notification.object;
    NSNumber * fareId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
    if(_ticket != nil && [fareId isEqualToNumber:_ticket.fare_id]){
        [self resetInterfaceToHome];
    }
    _ticket = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setTicket:(Ticket *)ride {
    _ticket = ride;
    self.transit = ride;
}

- (void) showHome{
    //Replaced homeActionView with editCommuteButton for this version
    
    CGRect frame = _editCommuteButton.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - 53;
    _editCommuteButton.frame = frame;
    [self.view addSubview:self.editCommuteButton];
    
    
    CGRect currentLocationframe = _currentLocationButton.frame;
    currentLocationframe.origin.x = 276;
    currentLocationframe.origin.y = self.view.frame.size.height - 101;
    _currentLocationButton.frame = currentLocationframe;
    [self.view addSubview:self.currentLocationButton];
    
    
}

- (void) addPedestrianRoute: (CLLocation *) from to: (CLLocation *) to {
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(from.coordinate.latitude, from.coordinate.longitude);
    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(to.coordinate.latitude, to.coordinate.longitude);
    
    [VCMapQuestRouting pedestrianRoute:fromCoordinate
                                    to:toCoordinate
                               success:^(MKPolyline *polyline, MKCoordinateRegion region) {
                                   polyline.title = @"pedestrian";
                                   [self.map addOverlay:polyline];
                               }
                               failure:^{
                                   NSLog(@"%@", @"Error talking with MapQuest routing API");
                               }];
}

- (void) addDriverLegRoute: (CLLocation *) from to: (CLLocation *) to {
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(from.coordinate.latitude, from.coordinate.longitude);
    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(to.coordinate.latitude, to.coordinate.longitude);
    
    [VCMapQuestRouting route:fromCoordinate
                          to:toCoordinate
                     success:^(MKPolyline *polyline, MKCoordinateRegion region) {
                         polyline.title = @"driver_leg";
                         [self.map addOverlay:polyline];
                     }
                     failure:^{
                         NSLog(@"%@", @"Error talking with MapQuest routing API");
                     }];
}

- (void) showInterfaceForTicket {
    [self clearMap];
    [self removeHuds];
    [self.editCommuteButton removeFromSuperview];
    [self showCancelBarButton];
    
    
    if([@[kCreatedState, kRequestedState] containsObject:_ticket.state]){
        [self addOriginAnnotation: [_ticket originLocation] ];
        [self addDestinationAnnotation: [_ticket destinationLocation]];
        [self showSuggestedRoute: [_ticket originLocation] to:[_ticket destinationLocation]];
        [self.view addSubview:self.holdingScreen];
        
    } else if([_ticket.state isEqualToString:kCommuteSchedulerFailedState]) {
        [self hideCancelBarButton];
        [_holdingScreen transitionToRideRequestDenied];
        [self addHoldingScreenIfNotAdded];
        
    } else if([_ticket.state isEqualToString:kScheduledState]){
        
        [self updateMapForTicket:_ticket];
        
        if([_ticket.confirmed boolValue]){
            
            // show the HUD interface
            if([_ticket.driving boolValue] ) {
                [self showHovDriverInterface];
            } else {
                [self showRiderInterface];
            }
            
        } else {
            
            [self hideCancelBarButton];
            [_holdingScreen transitionToRideRequestApproved:_ticket];
            [self addHoldingScreenIfNotAdded];
            
        }
    }
    
}

- (void) updateMapForTicket:(Ticket *) ticket {
    //[self addOriginAnnotation: [ticket originLocation] ];
    //[self addDestinationAnnotation: [ticket destinationLocation]];
    [self addMeetingPointAnnotation: [ticket meetingPointLocation]];
    [self addDropOffPointAnnotation: [ticket dropOffPointLocation]];
    [self.map selectAnnotation:_meetingPointAnnotation animated:YES];
    
    [self showSuggestedRoute: [_ticket meetingPointLocation] to:[_ticket dropOffPointLocation]];
    if( [_ticket.driving boolValue] ) {
        if(![[_ticket meetingPointLocation] isEqual:[_ticket originLocation]]){
            [self addDriverLegRoute:[_ticket originLocation] to:[_ticket meetingPointLocation]];
        }
        if(![[_ticket dropOffPointLocation] isEqual:[_ticket destinationLocation]]){
            [self addDriverLegRoute:[_ticket dropOffPointLocation] to:[_ticket destinationLocation]];
        }
    } else {
        [self addPedestrianRoute:[_ticket originLocation] to:[_ticket meetingPointLocation]];
        [self addPedestrianRoute:[_ticket dropOffPointLocation] to:[_ticket destinationLocation]];
    }
    
}

- (void) showCancelBarButton {
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancel:)];
    self.navigationItem.rightBarButtonItem = cancelItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:(182/255.f) green:(31/255.f) blue:(36/255.f) alpha:1.0];
}


- (void) hideCancelBarButton {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) transitionToEditCommute {
    [_editCommuteButton removeFromSuperview]; //homeActionView goes here
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
        if([[VCUserStateManager instance] isHovDriver]){
            CGRect frame = _hovDriverOptionView.frame;
            frame.origin.x = 0;
            frame.origin.y = self.view.frame.size.height - 91;
            _hovDriverOptionView.frame = frame;
            [self.view addSubview:_hovDriverOptionView];
        }
    }
    {
        _scheduleRideButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        if( [[VCCommuteManager instance] hasSettings] ){
            _scheduleRideButton.titleLabel.text = @"COMMUTE TOMORROW";
        } else {
            _scheduleRideButton.titleLabel.text = @"SAVE MY COMMUTE";
        }
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
    if([[VCCommuteManager instance] hasSettings]){
        [self showSuggestedRoute:[VCCommuteManager instance].home to:[VCCommuteManager instance].work];
    } else {
        [self zoomToCurrentLocation];
    }
    
    CGRect currentLocationframe = _currentLocationButton.frame;
    currentLocationframe.origin.x = 271;
    currentLocationframe.origin.y = self.view.frame.size.height - 46;
    _currentLocationButton.frame = currentLocationframe;
    [self.view addSubview:self.currentLocationButton];
    
    [_editCommuteButton removeFromSuperview]; //homeActionView goes here
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

- (void) resetInterfaceToHome {
    [self clearMap];
    [UIView transitionWithView:self.view duration:.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self removeHuds];
        [self hideCancelBarButton];
        [self showHome];
        
        // check for another scheduled commute
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"state = %@", @"scheduled"];
        NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
        [fetch setPredicate:predicate];
        NSError * error;
        NSArray * tickets = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
        if(tickets == nil){
            [WRUtilities criticalError:error];
        } else {
            if([tickets count] > 0){
                // we have a scheduled ticket still.  don't show the commute tomorrow button
                _editCommuteButton.hidden = YES;
            }
        }
        
    } completion:^(BOOL finished) {
        if([[VCCommuteManager instance] hasSettings]){
            [self addOriginAnnotation: [VCCommuteManager instance].home ];
            [self addDestinationAnnotation: [VCCommuteManager instance].work ];
            [self showSuggestedRoute:[VCCommuteManager instance].home to:[VCCommuteManager instance].work];
        } else {
            [self zoomToCurrentLocation];
        }
    }];
    
}

- (void) clearMap {
    [super clearMap];
    for( id<MKOverlay> overlay in self.map.overlays) {
        if(![overlay isEqual:_tileOverlay]){
            [self.map removeOverlay:overlay];
        }
    }
    [self.map removeAnnotation:_originAnnotation];
    [self.map removeAnnotation:_destinationAnnotation];
    [self.map removeAnnotation:_meetingPointAnnotation];
    [self.map removeAnnotation:_dropOffPointAnnotation];
    
}

- (void) removeHuds {
    [_holdingScreen removeFromSuperview];
    [_holdingScreen resetView];
    
    [self.scrollView removeFromSuperview];
    
    [_pickupHudView removeFromSuperview];
    [_homeLocationWidget.view removeFromSuperview];
    [_workLocationWidget.view removeFromSuperview];
    [_returnHudView removeFromSuperview];
    [_scheduleRideButton removeFromSuperview];
    [_hovDriverOptionView removeFromSuperview];
    [_nextButton removeFromSuperview];
    [_rideItineraryView removeFromSuperview];
    [_rideDetailsHud removeFromSuperview];
    [_driverCallHUD removeFromSuperview];
    [_driverCancelHUD removeFromSuperview];
    [_ridersPickedUpButton removeFromSuperview];
    [_rideCompleteButton removeFromSuperview];
    [_fareDetailsView removeFromSuperview];
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
    _whichPicker = kPickerReturnTime;
    [ActionSheetCustomPicker showPickerWithTitle:@"Return Time"
                                        delegate:self
                                showCancelButton:YES
                                          origin:_returnHudView ];
}

- (void) showPickupTimePicker {
    _whichPicker = kPickerPickupTime;
    [ActionSheetCustomPicker showPickerWithTitle:@"Pickup Time"
                                        delegate:self
                                showCancelButton:YES
                                          origin:_pickupHudView ];
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
    
    
    if([[VCUserStateManager instance] isHovDriver]){
        CGRect frame = _hovDriverOptionView.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.frame.size.height - 91;
        _hovDriverOptionView.frame = frame;
        [self.view addSubview:_hovDriverOptionView];
    }
    
    
    {
        if( [[VCCommuteManager instance] hasSettings] ){
            _scheduleRideButton.titleLabel.text = @"COMMUTE TOMORROW";
        } else {
            _scheduleRideButton.titleLabel.text = @"SAVE COMMUTE";
        }
        CGRect frame = _scheduleRideButton.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.frame.size.height - 53;
        _scheduleRideButton.frame = frame;
        [self.view addSubview:_scheduleRideButton];
    }
}

- (void) transitionToWaitingScreen {
    [self showCancelBarButton];
    [_scheduleRideButton removeFromSuperview];
    [self.view addSubview:self.holdingScreen];
    [self showCancelBarButton];
    _step = kStepDone;
}

- (void) transitionToRideDetailsConfirmation {
    
    if([[self.view subviews] containsObject:_holdingScreen]){
        [_holdingScreen removeFromSuperview];
    }
    
    [self updateRideDetailsConfirmationView: _ticket];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.bounces = NO;
    CGRect frame = self.view.frame;
    frame.origin.y = frame.origin.y + 62;
    frame.size.height = frame.size.height - 62;
    self.scrollView.frame = frame;
    [self.view addSubview:self.scrollView];
    [self.scrollView setContentSize:_rideItineraryView.frame.size];
    [self.scrollView addSubview:_rideItineraryView];
    
    
}

- (void) updateRideDetailsConfirmationView:(Ticket *) ticket {
    
    [UIView animateWithDuration: 1.0
                     animations:^{
                         
                         if([ticket.driving boolValue]) {
                             [_rideItineraryView driverLayout: ticket];
                             
                         } else {
                             [_rideItineraryView riderLayout: ticket];
                         }
                         
                     }];
    
    
}

- (void) didTapCancel: (id)sender {
    if(_ticket == nil) {
        [[VCCommuteManager instance] reset];
        [self resetInterfaceToHome];
    } else {
        [UIAlertView showWithTitle:@"Cancel Ride?" message:@"Are you sure you want to cancel this trip?" cancelButtonTitle:@"No!" otherButtonTitles:@[@"Yes, Cancel this ride"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch(buttonIndex){
                case 1:
                {
                    
                    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.labelText = @"Canceling..";
                    if([_ticket.confirmed boolValue]) {
                        [[VCCommuteManager instance] cancelRide:_ticket success:^{
                            [self resetInterfaceToHome];
                            _ticket = nil;
                            
                            hud.hidden = YES;
                        } failure:^{
                            hud.hidden = YES;
                        }];
                    } else {
                        // Here we are cancelling BOTH legs of the trip
                        [[VCCommuteManager instance] cancelTrip:_ticket.trip_id success:^{
                            [self resetInterfaceToHome];
                            _ticket = nil;
                            hud.hidden = YES;
                        } failure:^{
                            hud.hidden = YES;
                        }];
                    }
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
        NSString * placeName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        [editLocationWidget setLocationText: placeName ];
        editLocationWidget.mode = kEditLocationWidgetDisplayMode;
        editLocationWidget.waiting = NO;
        if(editLocationWidget.type == kHomeType){
            [VCCommuteManager instance].homePlaceName = placeName;
        } else if(editLocationWidget.type == kWorkType){
            [VCCommuteManager instance].workPlaceName = placeName;
        }
    }];
}

- (void) storeCommuterSettings: (void ( ^ ) ()) success failure:( void ( ^ ) ()) failure {
    [VCCommuteManager instance].home = [[CLLocation alloc] initWithLatitude:_originAnnotation.coordinate.latitude
                                                                  longitude:_originAnnotation.coordinate.longitude];
    [VCCommuteManager instance].work = [[CLLocation alloc] initWithLatitude:_destinationAnnotation.coordinate.latitude
                                                                  longitude:_destinationAnnotation.coordinate.longitude];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[VCCommuteManager instance] save:^{
        [hud hide:YES];
        success();
    } failure:^{
        [hud hide:YES];
        failure();
    }];
    
    
}

- (void) loadCommuteSettings {
    if( [VCCommuteManager instance].pickupTime != nil){
        _pickupTimeLabel.text = [VCCommuteManager instance].pickupTime;
    }
    
    if( [VCCommuteManager instance].home != nil){
        [self addOriginAnnotation: [VCCommuteManager instance].home ];
        [_homeLocationWidget setMode:kEditLocationWidgetDisplayMode];
        [_homeLocationWidget setLocationText:[VCCommuteManager instance].homePlaceName];
        
    }
    
    if( [VCCommuteManager instance].work != nil){
        [self addDestinationAnnotation: [VCCommuteManager instance].work ];
        [_workLocationWidget setMode:kEditLocationWidgetDisplayMode];
        [_workLocationWidget setLocationText:[VCCommuteManager instance].workPlaceName];
        
    }
    
    if( [VCCommuteManager instance].returnTime != nil){
        _returnTimeLabel.text = [VCCommuteManager instance].returnTime;
    }
    
    _hovDriveYesButton.selected = [VCCommuteManager instance].driving;
    
    if( [VCCommuteManager instance].home != nil && [VCCommuteManager instance].home != nil){
        [self showSuggestedRoute: [VCCommuteManager instance].home to:[VCCommuteManager instance].work];
    }
    
}

// Getting first location
- (void)startLocationUpdates {
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 500; // meters
    
    [_locationManager startUpdatingLocation];
}

- (void)stopLocationUpdates {
    [_locationManager stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(![[VCCommuteManager instance] hasSettings]) {
        [self zoomToCurrentLocation];
    }
    [self stopLocationUpdates];
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
    _destinationAnnotation.title = @"Work";
    [self.map addAnnotation:_destinationAnnotation];
}

- (void)addMeetingPointAnnotation:(CLLocation *)location {
    if(self.meetingPointAnnotation != nil){
        [self.map removeAnnotation:_meetingPointAnnotation];
    }
    _meetingPointAnnotation = [[MKPointAnnotation alloc] init];
    _meetingPointAnnotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    _meetingPointAnnotation.title = @"Meeting Point";
    _meetingPointAnnotation.subtitle = [_ticket.pickupTime time];
    [self.map addAnnotation:_meetingPointAnnotation];
}

- (void)addDropOffPointAnnotation:(CLLocation *)location {
    if(_dropOffPointAnnotation != nil){
        [self.map removeAnnotation:_dropOffPointAnnotation];
    }
    _dropOffPointAnnotation = [[MKPointAnnotation alloc] init];
    _dropOffPointAnnotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    _dropOffPointAnnotation.title = @"Drop Off";
    [self.map addAnnotation:_dropOffPointAnnotation];
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
    if([[VCCommuteManager instance] hasSettings]) {
        
        [self storeCommuterSettings:^{
            [self resetInterfaceToHome];
            [self scheduleCommuteForTomorrow];

            /*
            [UIAlertView showWithTitle:@"Just Checking..."
                               message:@"Have you been approved to schedule trips?  The system might not work properly if you have not"
                     cancelButtonTitle:@"No.."
                     otherButtonTitles:@[@"Yes"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  switch(buttonIndex){
                                      case 1:
                                      {
                                          [self scheduleCommuteForTomorrow];
                                      }
                                          
                                          break;
                                      default:
                                          break;
                                  }
                              }];
            */
        } failure:^{
            [UIAlertView showWithTitle:@"Error" message:@"There was a problem sending your request, you might want to try that again" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        }];
        
        
    } else {
        
        [self storeCommuterSettings:^{
            [UIAlertView showWithTitle:@"Your Setup is Complete!" message:@"We're processing your info and will contact you when it's time for you to start commuting!" cancelButtonTitle:@"Ok, Can't Wait!" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if([VCInterfaceManager instance].mode == kOnBoardingMode) {
                    self.navigationController.navigationBarHidden = NO;
                    [[VCInterfaceManager instance] showRiderInterface];
                } else {
                    [self resetInterfaceToHome];
                }
                
            } ];
            
        } failure:^{
            [UIAlertView showWithTitle:@"Error" message:@"There was a problem sending your request, you might want to try that again" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        }];
        
    }
    
}

- (void) scheduleCommuteForTomorrow {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *tomorrow = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[VCCommuteManager instance] requestRidesFor:tomorrow
                                         success:^{
                                             [hud hide:YES];
                                             [self transitionToWaitingScreen];
                                         } failure:^{
                                             [hud hide:YES];
                                             [UIAlertView showWithTitle:@"Error" message:@"There was a problem sending your request, you might want to try that again" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
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

- (IBAction)didTapShowRideDetailsButton:(id)sender {
    
    [self transitionToRideDetailsConfirmation];
    
}

- (IBAction)didTapPickupHud:(id)sender {
    [self showPickupTimePicker];
}


- (IBAction)didTapReturnHud:(id)sender {
    [self showReturnTimePicker];
}

- (IBAction)didTapConfirmedCommuterRide:(id)sender {
    
    _ticket.confirmed = [NSNumber numberWithBool:YES];
    _ticket.returnTicket.confirmed = [NSNumber numberWithBool:YES];
    [VCNotifications scheduleUpdated];
    [VCCoreData saveContext];
    
    [self showInterfaceForTicket];
}

- (IBAction)didTapZoomToRideBounds:(id)sender {
    if (_ticket != nil) {
        [self.map setRegion:self.rideRegion animated:YES];
    }
}

- (IBAction)didTapZoomToCurrentLocation:(id)sender {
    [self zoomToCurrentLocation];
}

- (IBAction)didTapCallDriver:(id)sender {
    Driver * driver = _ticket.driver;
    [self callPhone:driver.phone];
}

- (IBAction)didTapOKButton:(id)sender {
    _ticket.confirmed = [NSNumber numberWithBool:YES];
    [VCNotifications scheduleUpdated];
    [VCCoreData saveContext];
    [self resetInterfaceToHome];
}

#pragma mark - VCLocationSearchViewControllerDelegate

- (void) editLocationWidget:(VCEditLocationWidget *)widget didSelectMapItem:(MKMapItem *)mapItem {
    
    if(widget.type == kHomeType) {
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:mapItem.placemark.coordinate.latitude longitude:mapItem.placemark.coordinate.longitude];
        [self addOriginAnnotation:location];
        widget.waiting = NO;
        
        [VCCommuteManager instance].homePlaceName = widget.locationText;
        
        
    } else if (widget.type == kWorkType) {
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:mapItem.placemark.coordinate.latitude longitude:mapItem.placemark.coordinate.longitude];
        [self addDestinationAnnotation:location];
        widget.waiting = NO;
        
        [VCCommuteManager instance].workPlaceName = widget.locationText;
        
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
        [self resetInterfaceToHome];
    }
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if( _whichPicker == kPickerReturnTime) {
        return [_eveningOptions count];
    } else if ( _whichPicker == kPickerPickupTime) {
        return [_morningOptions count];
    }
    return 0;
}


#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if( _whichPicker == kPickerReturnTime) {
        return [_eveningOptions objectAtIndex:row];
    } else if ( _whichPicker == kPickerPickupTime) {
        return [_morningOptions objectAtIndex:row];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if( _whichPicker == kPickerReturnTime) {
        NSString * value = [_eveningOptions objectAtIndex:row];
        [VCCommuteManager instance].returnTime = value;
        _returnTimeLabel.text = value;
    } else if ( _whichPicker == kPickerPickupTime) {
        NSString * value = [_morningOptions objectAtIndex:row];
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
        pinAnnotationView.canShowCallout = true;
        
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

/*
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline * polyline = (MKPolyline *) overlay;
        if( [polyline.title isEqualToString:@"pedestrian"]) {
            MKPolylineRenderer*   aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
            aRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
            aRenderer.lineWidth = 4;
            aRenderer.lineDashPattern = @[[NSNumber numberWithInt:10], [NSNumber numberWithInt:6]];
            return aRenderer;
        } else if ([polyline.title isEqualToString:@"driver_leg"]) {
            MKPolylineRenderer*   aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
            aRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
            aRenderer.lineWidth = 4;
            return aRenderer;
        }
    } else if ([overlay isKindOfClass:[MBXRasterTileOverlay class]])
    {
        MKTileOverlayRenderer *renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        return renderer;
    } else {
        return [super mapView:mapView viewForOverlay:overlay];
    }
    
    return nil;
}
 */


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline * polyline = (MKPolyline *) overlay;
        if( [polyline.title isEqualToString:@"pedestrian"]) {
            MKPolylineRenderer*   aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
            aRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
            aRenderer.lineWidth = 4;
            aRenderer.lineDashPattern = @[[NSNumber numberWithInt:10], [NSNumber numberWithInt:6]];
            return aRenderer;
        } else if ([polyline.title isEqualToString:@"driver_leg"]) {
            MKPolylineRenderer*   aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
            aRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
            aRenderer.lineWidth = 4;
            return aRenderer;
        } else {
            MKPolylineRenderer*    aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
            aRenderer.strokeColor = [UIColor colorWithRed:17.0f / 256.0f green: 119.0f / 256.0f blue: 45.0f / 256.0f alpha:.7];
            aRenderer.lineWidth = 4;
            return aRenderer;
        }
    } else if ([overlay isKindOfClass:[MBXRasterTileOverlay class]]) {
        MKTileOverlayRenderer *renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        return renderer;
    } else {
        return [super mapView:mapView viewForOverlay:overlay];
    }
    
    
    
    
    return nil;
}


#pragma makr RiderInterface

- (void) showRiderInterface {
    _rideDetailsHud.driverFirstNameLabel.text = _ticket.driver.firstName;
    _rideDetailsHud.driverLastNameLabel.text = _ticket.driver.lastName;
    _rideDetailsHud.carTypeValueLabel.text = [_ticket.car summary];
    _rideDetailsHud.licenseValueLabel.text = _ticket.car.licensePlate;
    _rideDetailsHud.cardNicknamelabel.text = [VCUserStateManager instance].profile.cardBrand;
    _rideDetailsHud.cardNumberLabel.text = [VCUserStateManager instance].profile.cardLastFour;
    _rideDetailsHud.fareLabel.text = [VCUtilities formatCurrencyFromCents: _ticket.fixedPrice];
    CGRect frame = _rideDetailsHud.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - 154;
    _rideDetailsHud.frame = frame;
    [self.view addSubview:_rideDetailsHud];
}

#pragma mark HovDriverInterface
- (void) showHovDriverInterface{
    
    [self setupDriverHuds];
    if([_ticket.hovFare.state isEqualToString:@"started"]){
        [self moveFromPickupToRideInProgressInteface];
    }
    
}

- (void) setupDriverHuds {
    
    _driverCallHUD.riders = [_ticket.hovFare.riders allObjects];
    
    CGRect currentLocationframe = _currentLocationButton.frame;
    currentLocationframe.origin.x = 271;
    currentLocationframe.origin.y = self.view.frame.size.height - 46;
    _currentLocationButton.frame = currentLocationframe;
    [self.view addSubview:self.currentLocationButton];
    
    CGRect directionsListFrame = _directionsListButton.frame;
    directionsListFrame.origin.x = 224;
    directionsListFrame.origin.y = self.view.frame.size.height - 46;
    _directionsListButton.frame = directionsListFrame;
    [self.view addSubview:self.directionsListButton];
    
    CGRect ridersPickedUpFrame = _ridersPickedUpButton.frame;
    ridersPickedUpFrame.origin.x = 18;
    ridersPickedUpFrame.origin.y = self.view.frame.size.height - 46;
    _ridersPickedUpButton.frame = ridersPickedUpFrame;
    [self.view addSubview:self.ridersPickedUpButton];
    
    CGRect frame = _driverCallHUD.frame;
    frame.origin.x = kDriverCallHudOriginX;
    frame.origin.y = self.view.frame.size.height - kDriverCallHudOriginY;
    _driverCallHUD.frame = frame;
    
    [self.view addSubview:_driverCallHUD];
    
    {
        CGRect frame = _driverCancelHUD.frame;
        frame.origin.x = kDriverCancelHudOriginX;
        frame.origin.y = self.view.frame.size.height - kDriverCancelHudOriginY;
        _driverCancelHUD.frame = frame;
        
        [self.view addSubview:_driverCancelHUD];
    }
    
    {
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [_driverCallHUD addGestureRecognizer:panRecognizer];
    }
    
    {
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move2:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [_driverCancelHUD addGestureRecognizer:panRecognizer];
    }
    
}

-(void)move:(id)sender {
    
    if( _callHudPanLocked ) {
        return;
    }
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    if(_callHudOpen == NO) {
        
        if(translatedPoint.x > 0){
            return;
        }
        
        if(translatedPoint.x < kDriverCallHudOpenX - kDriverCallHudOriginX ){
            return;
        }
        
        if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
            CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:self.view];
            
            if(velocity.x < -2000) {
                [self animateCallHudToOpen];
            } else if(translatedPoint.x < -75){
                [self animateCallHudToOpen];
            } else {
                [self animateCallHudToClosed];
            }
            
            return;
        }
        
        CGRect frame = _driverCallHUD.frame;
        frame.origin.x = kDriverCallHudOriginX + translatedPoint.x;
        _driverCallHUD.frame = frame;
        if ( kDriverCallHudOriginX + translatedPoint.x <= kDriverCallHudOpenX ){
            [self animateCallHudToOpen];
        }
        
    } else {
        if(translatedPoint.x < 0){
            return;
        }
        
        if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
            [self animateCallHudToClosed];
        }
    }
}

-(void)move2:(id)sender {
    NSLog(@"%@", @"YO!");
    
    if( _cancelHudPanLocked ) {
        return;
    }
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    if(_cancelHudOpen == NO) {
        
        if(translatedPoint.x > 0){
            return;
        }
        
        if(translatedPoint.x < kDriverCallHudOpenX - kDriverCallHudOriginX ){
            return;
        }
        
        if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
            CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:self.view];
            
            if(velocity.x < -2000) {
                [self animateCancelHudToOpen];
            } else if(translatedPoint.x < -100){
                [self animateCancelHudToOpen];
            } else {
                [self animateCancelHudToClosed];
            }
            
            return;
        }
        
        CGRect frame = _driverCancelHUD.frame;
        frame.origin.x = kDriverCancelHudOriginX + translatedPoint.x;
        _driverCancelHUD.frame = frame;
        if ( kDriverCancelHudOriginX + translatedPoint.x <= kDriverCancelHudOpenX ){
            [self animateCancelHudToOpen];
        }
        
    } else {
        if(translatedPoint.x < 0){
            return;
        }
        
        if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
            [self animateCancelHudToClosed];
        }
    }
}

- (void) didTapCancelRide: (id)sender {
    
    if(_ticket != nil) {
        [UIAlertView showWithTitle:@"Cancel Trip?" message:@"Are you sure you want to cancel this trip?" cancelButtonTitle:@"No!" otherButtonTitles:@[@"Yes, Cancel this ride"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch(buttonIndex){
                case 1:
                {
                    [[VCCommuteManager instance] cancelRide:_ticket success:^{
                        [UIAlertView showWithTitle:@"Trip Cancelled" message:@"Fare Cancelled" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                        [self resetInterfaceToHome];
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



- (void) animateCallHudToOpen {
    _callHudPanLocked = YES;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(unlockCallHudPan:) userInfo:nil repeats:NO];
    
    [UIView animateWithDuration:0.15 animations:^{
        CGRect frame = _driverCallHUD.frame;
        frame.origin.x = kDriverCallHudOpenX;
        _driverCallHUD.frame = frame;
        _callHudOpen = YES;
    }];
    
}

- (void) animateCancelHudToOpen {
    _cancelHudPanLocked = YES;
    
    _cancelTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(unlockCancelHudPan:) userInfo:nil repeats:NO];
    
    [UIView animateWithDuration:0.15 animations:^{
        CGRect frame = _driverCancelHUD.frame;
        frame.origin.x = kDriverCancelHudOpenX;
        _driverCancelHUD.frame = frame;
        _cancelHudOpen = YES;
    }];
    
}

- (void) animateCallHudToClosed{
    _callHudPanLocked = YES;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(unlockCallHudPan:) userInfo:nil repeats:NO];
    
    [UIView animateWithDuration:0.15 animations:^{
        CGRect frame = _driverCallHUD.frame;
        frame.origin.x = kDriverCallHudOriginX;
        _driverCallHUD.frame = frame;
        _callHudOpen = NO;
    }];
    
}


- (void) animateCancelHudToClosed{
    _cancelHudPanLocked = YES;
    
    _cancelTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(unlockCancelHudPan:) userInfo:nil repeats:NO];
    
    [UIView animateWithDuration:0.15 animations:^{
        CGRect frame = _driverCancelHUD.frame;
        frame.origin.x = kDriverCancelHudOriginX;
        _driverCancelHUD.frame = frame;
        _cancelHudOpen = NO;
    }];
}


- (void) unlockCallHudPan:(id)sender {
    _callHudPanLocked = NO;
}


- (void) unlockCancelHudPan:(id)sender {
    _cancelHudPanLocked = NO;
}

- (void) callPhone:(NSString *) phoneNumber {
    if(phoneNumber == nil){
        [UIAlertView showWithTitle:@"Error" message:@"We don't have a phone number for that user" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    NSString *url = [@"telprompt://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) moveFromPickupToRideInProgressInteface {
    CGRect rideCompletedFrame = _rideCompleteButton.frame;
    rideCompletedFrame.origin.x = 18;
    rideCompletedFrame.origin.y = self.view.frame.size.height - 46;
    _rideCompleteButton.frame = rideCompletedFrame;
    
    [UIView transitionWithView:self.view duration:.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.view addSubview:_rideCompleteButton];
        [_ridersPickedUpButton removeFromSuperview];
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)didTapCallRider1:(id)sender {
    Rider * rider = [_driverCallHUD.riders objectAtIndex:0];
    [self callPhone:rider.phone];
}
- (IBAction)didTapCallRider2:(id)sender {
    Rider * rider = [_driverCallHUD.riders objectAtIndex:1];
    [self callPhone:rider.phone];
}
- (IBAction)didTapCallRider3:(id)sender {
    Rider * rider = [_driverCallHUD.riders objectAtIndex:2];
    [self callPhone:rider.phone];
}



- (IBAction)didTapRidersPickedUp:(id)sender {
    if( [VCUserStateManager instance].underwayFareId != nil){
        if(! [[VCUserStateManager instance].underwayFareId isEqualToNumber: _ticket.fare_id]){
            [WRUtilities warningWithString:@"State shows another ride is still underway.  Continuing anyway"];
        }
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Notifying Server";
    
    [VCUserStateManager instance].underwayFareId = _ticket.fare_id;
    [VCDriverApi ridersPickedUp:_ticket.fare_id
                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            [self moveFromPickupToRideInProgressInteface];
                            _ticket.hovFare.state = @"started";
                            [VCCoreData saveContext];
                            [VCUserStateManager instance].driveProcessState = kUserStateRideStarted;
                            [hud hide:YES];
                            
                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                            [hud hide:YES];
                            
                        }];
    
}

- (IBAction)didTapRideCompleted:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Notifying Server";
    
    [VCDriverApi fareCompleted:_ticket.fare_id
                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                           [VCUserStateManager instance].driveProcessState = kUserStateRideCompleted;
                           //[self showRideCompletedInterface];
                           VCFare * fare = mappingResult.firstObject;
                           [VCUserStateManager instance].underwayFareId = nil;
                           
                           _ticket.state = kCompleteState;
                           [VCCoreData saveContext];
                           [VCNotifications scheduleUpdated];
                           [hud hide:YES];
                           
                           [_driverCallHUD removeFromSuperview];
                           [_driverCancelHUD removeFromSuperview];
                           [_rideCompleteButton removeFromSuperview];
                           [self resetInterfaceToHome];
                           
                           [UIAlertView showWithTitle:@"Receipt"
                                              message:[NSString stringWithFormat:@"Thanks for driving.  You earned %@ on this ride.",
                                                       [VCUtilities formatCurrencyFromCents:fare.driverEarnings]]
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil
                                             tapBlock:nil];
                           
                       } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                           [hud hide:YES];
                           
                       }];
    
}



- (IBAction)didChangeDisplayDirectionValue:(id)sender {
    
    switch(_rideItineraryView.segmentedButton.selectedSegmentIndex){
        case 0:
            [self updateRideDetailsConfirmationView:_ticket];
            [self updateMapForTicket:_ticket];
            break;
        case 1:
            [self updateRideDetailsConfirmationView:_ticket.returnTicket];
            [self updateMapForTicket:_ticket.returnTicket];
            break;
    }
    
}

- (void) addHoldingScreenIfNotAdded {
    if([_holdingScreen superview] == nil) {
        CGRect frame = _holdingScreen.frame;
        frame.size.height = self.view.frame.size.height;
        _holdingScreen.frame = frame;
        [self.view addSubview:_holdingScreen];
    }
}


//TODO: here are the methods for displaying the DRIVER Ride Details

- (void) displayDriverRideDetails {
    
    //[self hideCarValues];
    //[self showDriverDetails];
    
    
}



@end
