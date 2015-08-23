//
//  VCRideViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTicketViewController.h"
@import AddressBookUI;
#import <MBProgressHUD.h>
#import <Masonry.h>
#import "IIViewDeckController.h"

#import "VCNotifications.h"
#import "VCInterfaceManager.h"

#import "VCDriverApi.h"
#import "VCPushApi.h"

#import "Driver.h"
#import "Car.h"

#import "VCLabel.h"
#import "VCButtonBold.h"
#import "VCEditLocationWidget.h"
#import "VCCommuteManager.h"
#import "VCAbstractRideDetailsView.h"
#import "VCRideDetailsView.h"
#import "VCRideOverviewHudView.h"
#import "NSDate+Pretty.h"
#import "VCUserStateManager.h"
#import "VCMapQuestRouting.h"
#import "VCButton.h"
#import "IIViewDeckController.h"
#import "VCFare.h"
#import "VCUtilities.h"

#import "VCDriverTicketView.h"
#import "VCRiderTicketView.h"
#import "VCRideRequestView.h"

#import "VCLocationSearchViewController.h"
#import "VCMapHelper.h"
#import "VCMapStyle.h"
#import "VCMapConstants.h"
#import "VCStyle.h"
#import "VCFancyButton.h"

// provisional
#import "VCRiderApi.h"
#import "VCPickupPoint.h"

#define kCommuteStateBackEmpty -1
#define kCommuteStateNone 0
#define kCommuteStatePending 1
#define kCommuteStateScheduled 2
#define kCommuteStateBackHome 3

#define kNotificationLocationFound @"kNotificationLocationFound"

@interface VCTicketViewController () <RMMapViewDelegate, CLLocationManagerDelegate, VCRideRequestViewDelegate, VCLocationSearchViewControllerDelegate, VCRiderTicketViewDelegate, VCDriverTicketViewDelegate>

// Model
@property(strong, nonatomic) Route * route;

// Map
@property (strong, nonatomic) RMMapView * map;
@property (strong, nonatomic) RMAnnotation * routeOverlay;
@property (strong, nonatomic) CLGeocoder * geocoder;
@property (nonatomic) MBRegion *rideRegion;
@property (strong, nonatomic) RMAnnotation * originAnnotation;
@property (strong, nonatomic) RMPointAnnotation * destinationAnnotation;
@property (strong, nonatomic) RMPointAnnotation * meetingPointAnnotation;
@property (strong, nonatomic) RMPointAnnotation * dropOffPointAnnotation;
@property (strong, nonatomic) RMAnnotation * activeAnnotation;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) CLLocation * lastLocation;
@property (nonatomic) BOOL initialZoomComplete;

// provisional
@property (strong, nonatomic) NSArray * pickupPoints;
@property (strong, nonatomic) NSMutableArray * pickupPointAnnotations;

- (void) clearMap;
- (void) clearRoute;
- (void) zoomToCurrentLocation;
- (IBAction)didTapCurrentLocationButton:(id)sender;



// Ride Details
@property (strong, nonatomic) VCRiderTicketView * riderTicketHUD;
@property (strong, nonatomic) VCDriverTicketView * driverTicketHUD;
@property (strong, nonatomic) VCFancyButton *ridersOnboardButton;
@property (nonatomic) NSInteger riderTicketHUDBottom;

// State
@property (nonatomic) BOOL appeared;
@property (weak, nonatomic) Ticket * showingTicket;


//Ride Status
@property (strong, nonatomic) IBOutlet VCButton *ridersPickedUpButton;
@property (strong, nonatomic) IBOutlet VCButton *rideCompleteButton;


//Ride requeset
@property (nonatomic, strong) VCRideRequestView * rideRequestView;
@property (strong, nonatomic) IBOutlet UIView *waitingMessageView;

// Location Search
@property (strong, nonatomic) IBOutlet UIView *locationSearchForm;
@property (strong, nonatomic) IBOutlet UIButton *locationUpdateDoneButton;
@property (weak, nonatomic) IBOutlet UITextField *locationSearchField;
@property (strong, nonatomic) VCLocationSearchViewController * locationSearchTable;
@property (nonatomic) NSInteger editLocationType;
@property (strong, nonatomic) MKPlacemark * activePlacemark;
@property (nonatomic) BOOL inAddressLookupMode;

// Colors
@property (nonatomic, strong) UIColor * barButtonItemColor;


@end

@implementation VCTicketViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _appeared = NO;
        _ticket = nil;
        _barButtonItemColor = [UIColor colorWithRed:(182/255.f) green:(31/255.f) blue:(36/255.f) alpha:1.0];
        _geocoder = [[CLGeocoder alloc] init];
        _initialZoomComplete = NO;
        _inAddressLookupMode = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startLocationUpdates];
    
    // Look for pending ticket
    if(_ticket == nil) {
        _ticket = [[VCCommuteManager instance] getDefaultTicket];
    }
    
    // Provisional
    /*
    [VCRiderApi getPickupPointsWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        _pickupPoints = [mappingResult array];
        [self buildPickupPointAnnotations];
        [self addPickupPointAnnotations];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
    }];
     */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleUpdated:) name:kNotificationScheduleUpdated object:nil];

}


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self loadCommuteSettings];
    
    if(!_appeared){
        
        RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"aluvimaps.32wfoe6l"];
        self.map = [[RMMapView alloc] initWithFrame:self.view.frame andTilesource:tileSource];
        self.map.adjustTilesForRetinaDisplay = YES;
        self.map.delegate = self;
        self.map.userTrackingMode = RMUserTrackingModeNone;
        self.map.showsUserLocation = YES;
        [self.map setConstraintsSouthWest:CLLocationCoordinate2DMake(26, -126) northEast:CLLocationCoordinate2DMake(49, -63)];
        [self.view insertSubview:self.map atIndex:0];
        
        _appeared = YES;
        
        // Delay execution of my block for the MapBox software to fully load and move to correct place on the map
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25), dispatch_get_main_queue(), ^{
            [self updateTicketInterface];
        });
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripFulfilled:) name:kNotificationTypeTripFulfilled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripUnfulfilled:) name:kNotificationTypeTripUnfulfilled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareCompleted:) name:kNotificationTypeFareComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareCancelledByDriver:) name:kPushTypeFareCancelledByDriver object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareCancelledByRider:) name:kPushTypeFareCancelledByRider object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFound:) name:kNotificationLocationFound object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _isFinished = YES;
}


- (void) scheduleUpdated:(NSNotification *) notification {
    Ticket * defaultTicket = [[VCCommuteManager instance] getDefaultTicket];
    if(_ticket != nil && defaultTicket == nil){
        _ticket = nil;
        [self updateTicketInterface];
    } else if(_ticket == nil && defaultTicket != nil){
        _ticket = defaultTicket;
        [self updateTicketInterface];
    }
}



///////////////////
///////////////////   Handle State Updates
///////////////////

- (void) tripFulfilled:(NSNotification *) notification {
    NSLog(@"%@", [notification.object debugDescription]);
    NSNumber * tripId = [notification.object objectForKey:VC_PUSH_TRIP_ID_KEY];
    if(_ticket == nil || [_ticket.trip_id isEqualToNumber:tripId]) {
        NSArray * ticketsForTrip = [Ticket ticketsForTrip:tripId];
        _ticket = [ticketsForTrip objectAtIndex:0];
        if(_ticket == nil){
            [WRUtilities criticalErrorWithString:@"Missing ticket for trip."];
            return;
        }
        [self hideWaitinMessageView];
        [self updateTicketInterface];
    } else {
        // some debugging
        if(_ticket == nil){
            [WRUtilities triage:@"Nil ticket"];
        } else {
            [WRUtilities triage:[NSString stringWithFormat:@"Viewing a different ticket %@", [_ticket debugDescription]]];
        }
    }
}

- (void) tripUnfulfilled:(NSNotification *) notification {
    _ticket = nil;
    [self resetInterfaceToHome];
    [self updateTicketInterface];
}

- (void) fareCompleted:(NSNotification *) notification {
    NSDictionary * payload = notification.object;
    NSNumber * fareId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
    if(_ticket != nil && [fareId isEqualToNumber:_ticket.fare_id]){
        [self resetInterfaceToHome];
    }
    _ticket = nil;
    [self updateTicketInterface];
}

- (void) fareCancelledByDriver:(NSNotification *) notification {
    NSDictionary * payload = notification.object;
    NSNumber * fareId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
    if(_ticket != nil && [fareId isEqualToNumber:_ticket.ride_id ]){
        [self resetInterfaceToHome];
    }
    _ticket = nil;
    [self updateTicketInterface];
}

- (void) fareCancelledByRider: (NSNotification *) notification {
    NSDictionary * payload = notification.object;
    NSNumber * fareId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
    if(_ticket != nil && [fareId isEqualToNumber:_ticket.fare_id]){
        [self resetInterfaceToHome];
    }
    _ticket = nil;
    [self updateTicketInterface];
    
}



//////////////
////////////// Map and Routes
//////////////


- (void) showDefaultRoute {
    if([_route routeCoordinateSettingsValid]){
        if([_route hasCachedPath]){
            [self showRoute:_route.polyline withRegion:_route.region withZoom:YES];
        } else {
            [self zoomToCurrentLocation];
            [self updateDefaultRouteWithZoom:YES];
        }
    } else {
        if(_routeOverlay != nil){
            [_map removeAnnotation:_routeOverlay];
        }
        [self zoomToCurrentLocation];
    }
}


- (void) updateDefaultRouteWithZoom: (BOOL) withZoom {
    
    [VCMapQuestRouting route:CLLocationCoordinate2DMake([_route getDefaultOrigin].coordinate.latitude, [_route getDefaultOrigin].coordinate.longitude)
                          to:CLLocationCoordinate2DMake(_route.work.coordinate.latitude, _route.work.coordinate.longitude)
                     success:^(NSArray *polyline, MBRegion *region) {
                         
                         _route.polyline = polyline;
                         _route.region = region;
                         [[VCCommuteManager instance] storeRoute:polyline withRegion:region];
                         [self showRoute:polyline withRegion:region withZoom:withZoom];
                         
                     } failure:^{
                         NSLog(@"%@", @"Error talking with MapQuest routing API");
                     }];
    
}

- (void) showTicketRouteWithZoom: (BOOL) withZoom {
    [self updateTicketRouteWithZoom: withZoom];
    /*
     Check in on route caching later
     if([_ticket hasCachedRoute]){
     [self showRoute:_ticket.polyline withRegion:_ticket.region];
     } else {
     [self updateTicketRoute];
     }
     */
}

- (void) showTicketRoute {
    [self showTicketRouteWithZoom:YES];
}

- (void) updateTicketRouteWithZoom: (BOOL) withZoom {
    
    [VCMapQuestRouting route:CLLocationCoordinate2DMake([_ticket.meetingPointLatitude doubleValue], [_ticket.meetingPointLongitude doubleValue])
                          to:CLLocationCoordinate2DMake([_ticket.dropOffPointLatitude doubleValue], [_ticket.dropOffPointLongitude doubleValue])
                     success:^(NSArray *polyline, MBRegion *region) {
                         
                         _ticket.polyline = polyline;
                         _ticket.region = region;
                         [self showRoute:polyline withRegion:region withZoom:withZoom];
                         
                     } failure:^{
                         NSLog(@"%@", @"Error talking with MapQuest routing API");
                     }];
    
}

- (void) showRoute:(NSArray*) polyline withRegion:(MBRegion * ) region withZoom:(BOOL) withZoom{
    if (_routeOverlay != nil) {
        [_map removeAnnotation:_routeOverlay];
    }
    
    if(! [region isValidRegion]){
        return;
    }
    
    _initialZoomComplete = YES;
    
    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                          coordinate:((CLLocation *)[polyline objectAtIndex:0]).coordinate
                                                            andTitle:@"suggested_route"];
    annotation.userInfo = polyline;
    [annotation setBoundingBoxFromLocations:polyline];
    
    [self.map addAnnotation:annotation];
    
    _routeOverlay = annotation;
    
    self.rideRegion = region;
    
    if(withZoom) {
        NSLog(@"Zoom To Region");
        [_map zoomWithLatitudeLongitudeBoundsSouthWest:[VCMapHelper paddedNELocation:region.southWest]
                                         northEast:[VCMapHelper paddedSWLocation:region.northEast]
                                          animated:YES];
    }
}


- (void) clearRoute {
    if (_routeOverlay != nil) {
        [self.map removeAnnotation:_routeOverlay];
    }
}


- (void) addPedestrianRoute: (CLLocation *) from to: (CLLocation *) to {
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(from.coordinate.latitude, from.coordinate.longitude);
    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(to.coordinate.latitude, to.coordinate.longitude);
    
    [VCMapQuestRouting pedestrianRoute:fromCoordinate
                                    to:toCoordinate
                               success:^(NSArray *polyline, MBRegion *region) {
                                   RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                                                         coordinate:((CLLocation *)[polyline objectAtIndex:0]).coordinate
                                                                                           andTitle:@"pedestrian"];
                                   annotation.userInfo = polyline;
                                   [annotation setBoundingBoxFromLocations:polyline];
                                   
                                   [self.map addAnnotation:annotation];
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
                     success:^(NSArray *polyline, MBRegion *region) {
                         RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                                               coordinate:((CLLocation *)[polyline objectAtIndex:0]).coordinate
                                                                                 andTitle:@"driver_leg"];
                         annotation.userInfo = polyline;
                         [annotation setBoundingBoxFromLocations:polyline];
                         
                         [self.map addAnnotation:annotation];
                     }
                     failure:^{
                         NSLog(@"%@", @"Error talking with MapQuest routing API");
                     }];
}






- (void) locationFound:(NSNotification *) notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLocationFound object:nil];
    if( ![_route routeCoordinateSettingsValid] && ! _initialZoomComplete ) {
        [self zoomToCurrentLocation];
    }
}

- (void) zoomToCurrentLocation {
    NSLog(@"Zoom To Current");
    
    if(self.map != nil && _lastLocation != nil) {
        [self.map setZoom:14 atCoordinate:_lastLocation.coordinate animated:YES];
    }
}


// IBOutlets
- (IBAction)didTapCurrentLocationButton:(id)sender {
    [self zoomToCurrentLocation];
}




- (void) loadCommuteSettings {
    _route = [[Route alloc] init];
    _route = [[VCCommuteManager instance].route copy];
    
}

- (void) showHome{
    //Replaced homeActionView with editCommuteButton for this version
    
    CGRect currentLocationframe = _currentLocationButton.frame;
    currentLocationframe.origin.x = 276;
    currentLocationframe.origin.y = self.view.frame.size.height - 101;
    _currentLocationButton.frame = currentLocationframe;
    [self.view addSubview:self.currentLocationButton];
    
    
}
- (void) didTapSwitchToBackHome:(id) sender {
    _ticket = [_ticket returnTicket];
    if(_ticket == nil){
        [WRUtilities criticalErrorWithString:@"No Return Ticket"];
    }
    [self updateTicketInterface];
}



////////////////
//////////////// Scheduling a Commute
////////////////

- (void) didTapScheduleMenuButton:(id)sender {
    [self prepareRideRequestViewEditable:YES];
    [self showRideRequestView];
    
}

- (void) didTapReviewScheduleMenuButton:(id)sender {
    [self prepareRideRequestViewEditable:NO];
    [self showRideRequestView];
    
}



- (void)prepareRideRequestViewEditable: (BOOL) editable {
    if(_rideRequestView == nil) {
        _rideRequestView = [WRUtilities getViewFromNib:@"VCRideRequestView" class:[VCRideRequestView class]];
    }
    _rideRequestView.delegate = self;
    
    [_rideRequestView setEditable:editable];
    [_rideRequestView updateWithRoute:_route];
    [self showRideRequestView];
    
}


- (void)showRideRequestView {
    CGRect frame = _rideRequestView.frame;
    frame.origin.x = 0;
    frame.origin.y = -self.view.frame.size.height;
    frame.size.width = self.view.frame.size.width;
    frame.size.height = self.view.frame.size.height;
    _rideRequestView.frame = frame;
    
    // add the view to the superview
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_rideRequestView];
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         // final placement
                         CGRect frame = _rideRequestView.frame;
                         frame.origin.y = 0;
                         _rideRequestView.frame = frame;
                     } completion:^(BOOL finished) {
                         
                     }];
}


- (void) setRightButtonForState:(NSInteger) state{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.backgroundColor = [UIColor whiteColor].CGColor;
    button.layer.cornerRadius = 5.0;
    button.layer.masksToBounds = NO;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.shadowColor = [VCStyle drkBlueColor].CGColor;
    button.layer.shadowOpacity = 1;
    button.layer.shadowRadius = 0;
    button.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    [button setFrame:CGRectMake(0, 0, 150, 28)];
    [button setTitleColor:[VCStyle greyColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Bryant-Regular" size:16.0];
    [button addTarget:self action:@selector(didTapScheduleMenuButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem;
    //self.toolbarItems = @[buttonItem];
    switch(state){
        case kCommuteStateNone:
        {
            [button setTitle:@"SCHEDULE RIDE" forState:UIControlStateNormal];
            [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [button addTarget:self action:@selector(didTapScheduleMenuButton:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case kCommuteStatePending:
        {
            button.titleLabel.font = [UIFont fontWithName:@"Bryant-Regular" size:14.0];
            [button setTitle:@"COMMUTE PENDING" forState:UIControlStateNormal];
            [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [button addTarget:self action:@selector(didTapReviewScheduleMenuButton:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.backgroundColor = [VCStyle drkBlueColor].CGColor;
            button.layer.borderColor = [VCStyle drkBlueColor].CGColor;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
        case kCommuteStateScheduled:
        {
            [button setTitle:@"CANCEL RIDE" forState:UIControlStateNormal];
            [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [button addTarget:self action:@selector(didTapCancelTicket:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case kCommuteStateBackHome:
        {
            [button setTitle:@"BACK HOME" forState:UIControlStateNormal];
            [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [button addTarget:self action:@selector(didTapSwitchToBackHome:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        default:
        {
            button = nil;
            break;
        }
            
    }
    if(button != nil) {
        buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = buttonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


- (void) updateTicketInterface {
    [self clearMap];
    [self removeHuds];
    
    if(_ticket == nil) {
        [self setRightButtonForState:kCommuteStateNone];
        
        if([_route routeCoordinateSettingsValid]) {
            // if commute IS set up already
            [self showHome];
            [self showDefaultRoute];
            [self addOriginAnnotation: [_route getDefaultOrigin]];
            [self addDestinationAnnotation: _route.work];
        }
        
        //provisional
        //add pickup points
        [self addPickupPointAnnotations];
        
    } else if([@[kCreatedState, kRequestedState] containsObject:_ticket.state]){
        
        [self setRightButtonForState:kCommuteStatePending];
        [self addOriginAnnotation: [_ticket originLocation] ];
        [self addDestinationAnnotation: [_ticket destinationLocation]];
        [self showDefaultRoute];
        [self showWaitingMessageView];
        
    } else if([@[kScheduledState, kInProgressState] containsObject:_ticket.state]){
        [self setRightButtonForState:kCommuteStateScheduled];
        
        [self addMeetingPointAnnotation: [_ticket meetingPointLocation]];
        [self addDropOffPointAnnotation: [_ticket dropOffPointLocation]];
        [self.map selectAnnotation:_meetingPointAnnotation animated:YES];
        
        [self showTicketRouteWithZoom:NO];
        [self.map setZoom:[VCMapStyle defaultZoomForType:kMeetingPointType] atCoordinate: [_ticket meetingPointCoordinate]  animated:YES];

        /*
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
         */
        
        // show the HUD interface
        if([_ticket.driving boolValue] ) {
            [self showDriverTicketHUD];
        } else {
            [self showRiderTicketHUD];
        }
        
        
    } else if([@[kCompleteState, kRiderCancelledState, kDriverCancelledState] containsObject:_ticket.state]){
        if([_ticket.direction isEqualToString:@"a"]){
            [self setRightButtonForState:kCommuteStateBackHome];
        } else {
            [self setRightButtonForState:kCommuteStateBackEmpty];
        }
        [self addMeetingPointAnnotation: [_ticket meetingPointLocation]];
        [self addDropOffPointAnnotation: [_ticket dropOffPointLocation]];
        [self showTicketRoute];
        
    }
    
}

- (void) removeHuds {
    [_ridersPickedUpButton removeFromSuperview];
    [_rideCompleteButton removeFromSuperview];
    [_riderTicketHUD removeFromSuperview];
    [_driverTicketHUD removeFromSuperview];
}


- (void) resetInterfaceToHome {
    [self clearMap];
    [self hideWaitinMessageView];
    [UIView transitionWithView:self.view duration:.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self removeHuds];
        [self updateTicketInterface];
        
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
                //_editCommuteButton.hidden = YES;
            }
        }
        
    } completion:^(BOOL finished) {
        [self showDefaultRoute];
    }];
    
}

- (void) clearMap {
    if (_originAnnotation != nil) {
        
        [self.map removeAnnotation:_originAnnotation];
        _originAnnotation = nil;
    }
    if (_destinationAnnotation != nil) {
        
        [self.map removeAnnotation:_destinationAnnotation];
        _destinationAnnotation = nil;
    }
    if (_meetingPointAnnotation != nil) {
        
        [self.map removeAnnotation:_meetingPointAnnotation];
        _meetingPointAnnotation = nil;
    }
    if (_dropOffPointAnnotation != nil) {
        
        [self.map removeAnnotation:_dropOffPointAnnotation];
        _dropOffPointAnnotation = nil;
    }
    if (_activeAnnotation != nil) {
        
        [self.map removeAnnotation:_activeAnnotation];
        _activeAnnotation = nil;
    }
    [self.map removeAnnotations:_pickupPointAnnotations];
    [self clearRoute];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint translation = [recognizer translationInView:self.view];
        
        _riderTicketHUDBottom += translation.y;
        
        // recognize values of _riderTicketHUDBottom that are not good
        if(_riderTicketHUDBottom > 100){
            return;
        }
        
       
        
        [_riderTicketHUD mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.bottom.equalTo(self.view.mas_bottom).with.offset(_riderTicketHUDBottom);
            make.right.equalTo(self.view.mas_right);
            make.height.mas_equalTo(_riderTicketHUD.frame.size.height);
        }];
        
        
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
}



- (void) showRiderTicketHUD {
    _riderTicketHUD = [WRUtilities getViewFromNib:@"VCRiderTicketView" class:[VCRiderTicketView class]];
    _riderTicketHUD.delegate = self;
    [_riderTicketHUD updateInterfaceWithTicket:_ticket];
    UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_riderTicketHUD.upButton addGestureRecognizer:pangr];

    
    [self.view addSubview:_riderTicketHUD];
    [_riderTicketHUD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(_riderTicketHUD.frame.size.height);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(_driverTicketHUD.frame.size.height);
    }];
    
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                     
                         _riderTicketHUDBottom = 0;
                         [_riderTicketHUD mas_remakeConstraints:^(MASConstraintMaker *make) {
                             make.left.equalTo(self.view.mas_left);
                             make.bottom.equalTo(self.view.mas_bottom);
                             make.right.equalTo(self.view.mas_right);
                             make.height.mas_equalTo(_riderTicketHUD.frame.size.height);
                         }];
                         
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (void) VCDriverTicketView: (VCDriverTicketView *) drive didTapCallRider:(NSString *)phoneNumber {
    [self callPhone:phoneNumber];
}

- (void)VCDriverTicketViewDidTapCommuteCompleted:(VCDriverTicketView *)driverTicketView {
    
}

- (void) showDriverTicketHUD {
    _driverTicketHUD = [WRUtilities getViewFromNib:@"VCDriverTicketView" class:[VCDriverTicketView class]];
    _driverTicketHUD.delegate = self;
    [_driverTicketHUD updateInterfaceWithTicket:_ticket];
    
    
    [self.view addSubview:_driverTicketHUD];
    [_driverTicketHUD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(_driverTicketHUD.frame.size.height);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(_driverTicketHUD.frame.size.height);
    }];
    
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         // final placement
                         CGRect frame = _driverTicketHUD.frame;
                         frame.origin.y = 380;
                         _driverTicketHUD.frame = frame;
                         
                         [_driverTicketHUD mas_remakeConstraints:^(MASConstraintMaker *make) {
                             make.left.equalTo(self.view.mas_left);
                             make.bottom.equalTo(self.view.mas_bottom);
                             make.right.equalTo(self.view.mas_right);
                             make.height.mas_equalTo(_driverTicketHUD.frame.size.height);
                         }];
                         
                         
                     } completion:^(BOOL finished) {
                         
                         
                         _ridersOnboardButton = [[VCFancyButton alloc] init];
                         [_ridersOnboardButton style];
                         CGRect frame = CGRectMake(0, 0, 160, 50);
                         _ridersOnboardButton.frame = frame;
                        
                         [self.view addSubview:_ridersOnboardButton];
                         [_ridersOnboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
                             make.width.mas_equalTo(_ridersOnboardButton.frame.size.width);
                             make.bottom.equalTo(_driverTicketHUD.mas_top);
                             make.right.equalTo(self.view.mas_right);
                             make.height.mas_equalTo(_ridersOnboardButton.frame.size.height);
                         }];
                         
                         [self updateRidersOnBoardButton];
                  }];
}

- (void) updateRidersOnBoardButton {
    _ridersOnboardButton.hidden = NO;
    if([_ticket.state isEqualToString:kScheduledState]){
        [_ridersOnboardButton setTitle:@"Riders On Board" forState:UIControlStateNormal];
        [_ridersOnboardButton addTarget:self action:@selector(didTapRidersOnboardButton:) forControlEvents:UIControlEventTouchUpInside];
    } else  if([_ticket.state isEqualToString:kInProgressState]){
        [_ridersOnboardButton setTitle:@"Riders Dropped Off" forState:UIControlStateNormal];
        [_ridersOnboardButton addTarget:self action:@selector(didTapRidersDroppedOff:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        _ridersOnboardButton.hidden = YES;
    }

}

- (void)didTapRidersOnboardButton:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[VCCommuteManager instance] ridesPickedUp:_ticket success:^{
        hud.hidden = YES;
        [self updateRidersOnBoardButton];
    } failure:^{
        hud.hidden = YES;
        // do we want to say something?
    }];

}

- (void)didTapRidersDroppedOff:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[VCCommuteManager instance] ridesDroppedOff:_ticket success:^{
        hud.hidden = YES;
        [self updateRidersOnBoardButton];
        [self updateTicketInterface];
    } failure:^{
        hud.hidden = YES;
        // do we want to say something?
    }];
}


- (void) didTapCancelTicket: (id)sender {
    if(_ticket == nil) {
        [[VCCommuteManager instance] reset];
        [self resetInterfaceToHome];
    } else {
        [UIAlertView showWithTitle:@"Cancel Ride?" message:@"Are you sure you want to cancel this ride?" cancelButtonTitle:@"No!" otherButtonTitles:@[@"Yes, Cancel this ride"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch(buttonIndex){
                case 1:
                {
                    [self cancel];
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void) cancel {
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Canceling..";
    if( [@[kCreatedState, kRequestedState] containsObject: _ticket.state]) {
        // Here we are cancelling BOTH legs of the trip
        [[VCCommuteManager instance] cancelTrip:_ticket.trip_id success:^{
            _ticket = nil;
            [self resetInterfaceToHome];
            hud.hidden = YES;
        } failure:^{
            hud.hidden = YES;
        }];
        
    } else {
        
        [[VCCommuteManager instance] cancelRide:_ticket success:^{
            [[VCCoreData managedObjectContext]  refreshObject:_ticket mergeChanges:YES];
            if([_ticket.trip_state isEqualToString:@"aborted"] || _ticket.isDeleted){
                _ticket = nil;
            }
            [self resetInterfaceToHome];
            [self updateTicketInterface];
            hud.hidden = YES;
         } failure:^{
             hud.hidden = YES;
         }];
        
    }
    
}






/////////////
///////////// Annotations
/////////////
- (void)addOriginAnnotation:(CLLocation *)location {
    if(_originAnnotation != nil) {
        [self.map removeAnnotation:_originAnnotation];
        _originAnnotation = nil;
    }
    
    if(_route.driving) {
        _originAnnotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                       coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                         andTitle:@"Home"];
        _originAnnotation.userInfo = kPickupZoneAnnotationType;
    } else {
        _originAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                            coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                              andTitle:@"Home"];
        ((RMPointAnnotation *) _originAnnotation ).image = [VCMapStyle homePinImage];
    }
    [self.map addAnnotation:_originAnnotation];
}

- (void)addDestinationAnnotation:(CLLocation *)location {
    if(_destinationAnnotation != nil) {
        [self.map removeAnnotation:_destinationAnnotation];
        _destinationAnnotation = nil;
    }
    _destinationAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                             coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                               andTitle:@"Work"];
    _destinationAnnotation.image = [VCMapStyle workPinImage];
    [self.map addAnnotation:_destinationAnnotation];
}

- (void)addMeetingPointAnnotation:(CLLocation *)location {
    if(_meetingPointAnnotation != nil) {
        [self.map removeAnnotation:_meetingPointAnnotation];
        _meetingPointAnnotation = nil;
    }
    _meetingPointAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                              coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                                andTitle:@"Meeting Point"];
    _meetingPointAnnotation.image = [VCMapStyle homePinImage];
    [self.map addAnnotation:_meetingPointAnnotation];
}

- (void)addDropOffPointAnnotation:(CLLocation *)location {
    if(_dropOffPointAnnotation != nil){
        [self.map removeAnnotation:_dropOffPointAnnotation];
        _dropOffPointAnnotation = nil;
    }
    _dropOffPointAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                              coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                                andTitle:@"Drop Off"];
    _dropOffPointAnnotation.image = [VCMapStyle workPinImage];
    [self.map addAnnotation:_dropOffPointAnnotation];
}

- (void)buildPickupPointAnnotations {
    return;
    if(_pickupPoints != nil){
        _pickupPointAnnotations = [[NSMutableArray alloc] init];
        for (VCPickupPoint* pickupPoint in _pickupPoints)
        {
            RMPointAnnotation * annotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                                             coordinate:CLLocationCoordinate2DMake(pickupPoint.location.coordinate.latitude, pickupPoint.location.coordinate.longitude)
                                                                               andTitle:[NSString stringWithFormat:@"%@", pickupPoint.numberOfRiders]];
            annotation.userInfo = kPickupPointsAnnotationType;
            [_pickupPointAnnotations addObject:annotation];
        }
    }
}

- (void)addPickupPointAnnotations {
    return;
    [self.map addAnnotations:_pickupPointAnnotations];
}

///////////
///////////  Route and Scheduling
///////////


- (void) scheduleRide {
    [[VCCommuteManager instance] storeCommuterSettings:_route
                                               success:^{
                                                   [self resetInterfaceToHome];
                                                   [self scheduleCommuteForTomorrow];
                                                   
                                               } failure:^(NSString *errorMessage) {
                                                   [UIAlertView showWithTitle:@"Error" message:errorMessage cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                                   
                                               }];
    
}

- (void) scheduleCommuteForTomorrow {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *tomorrow = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[VCCommuteManager instance] requestRidesFor:tomorrow
                                        success: ^{
                                             [hud hide:YES];
                                             
                                             _ticket = [[VCCommuteManager instance] getDefaultTicket];
                                             [self updateTicketInterface];
                                             
                                         } failure:^{
                                             [hud hide:YES];
                                             [UIAlertView showWithTitle:@"Error" message:@"There was a problem sending your request, you might want to try that again" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                         }];
    
}

- (void) showWaitingMessageView {
    [self.view addSubview:_waitingMessageView];
    
    [_waitingMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top).with.offset(65);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(_waitingMessageView.frame.size.height);
    }];
    [_waitingMessageView setNeedsLayout];
    
}

- (void) hideWaitinMessageView {
    [_waitingMessageView removeFromSuperview];
}


- (IBAction)didTapZoomToRideBounds:(id)sender {
    if (_ticket != nil) {
        [self.map zoomWithLatitudeLongitudeBoundsSouthWest:self.rideRegion.southWest northEast:self.rideRegion.northEast animated:YES];
    }
}

- (IBAction)didTapZoomToCurrentLocation:(id)sender {
    [self zoomToCurrentLocation];
}

- (IBAction)didTapCallDriver:(id)sender {
    Driver * driver = _ticket.driver;
    [self callPhone:driver.phone];
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



- (IBAction)didTapRidersPickedUp:(id)sender {

    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Notifying Server";
    
    [VCDriverApi ridersPickedUp:_ticket.fare_id
                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            [self moveFromPickupToRideInProgressInteface];
                            _ticket.state = kInProgressState;
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
    
    [VCDriverApi ticketCompleted:_ticket.ride_id
                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             [VCUserStateManager instance].driveProcessState = kUserStateRideCompleted;
                             //[self showRideCompletedInterface];
                             VCFare * fare = mappingResult.firstObject;
                             
                             _ticket.state = kCompleteState;
                             [VCCoreData saveContext];
                             [VCNotifications scheduleUpdated];
                             [hud hide:YES];
                             
                             //[_driverCallHUD removeFromSuperview];
                             //[_driverCancelHUD removeFromSuperview];
                             [_rideCompleteButton removeFromSuperview];
                             [self resetInterfaceToHome];
                             
                             [UIAlertView showWithTitle:@"Receipt"
                                                message:[NSString stringWithFormat:@"Thanks for driving.  You earned %@ on this ride.",
                                                         [VCUtilities formatCurrencyFromCents:fare.driverEarnings]]
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil
                                               tapBlock:nil];
                             _ticket = nil;
                             
                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                             [hud hide:YES];
                             
                         }];
    
}




#pragma mark - VCRideRequestViewDelegate

- (void) rideRequestViewDidCancel: (VCRideRequestView *) rideRequestView {
    [self removeRideRequestView: rideRequestView];
    
}


- (void) rideRequestViewDidTapClose: (VCRideRequestView *) rideRequestView withChanges: (Route *) route {
    if([_route coordinatesDifferFrom:route] || route.driving != _route.driving){
        [route clearCachedPath];
    }
    _route = [route copy];  // TODO: Route should invalidate its own cache on coordinate changes
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[VCCommuteManager instance] storeCommuterSettings:_route
                                               success:^{
                                                   [hud hide:YES];
                                                   [self removeRideRequestView: rideRequestView];
                                                   [self updateTicketInterface];
                                                   
                                               } failure:^(NSString *errorMessage) {
                                                   [hud hide:YES];
                                                   [self removeRideRequestView: rideRequestView];
                                                   [self updateTicketInterface];
                                                   
                                               }];
}

- (void)rideRequestView:(VCRideRequestView *)rideRequestView didTapScheduleCommute:(Route *)route {
    if([_route coordinatesDifferFrom:route] || route.driving != _route.driving){
        [route clearCachedPath];
    }
    _route = [route copy];
    
    
    [[VCCommuteManager instance]storeCommuterSettings:_route
                                              success:^{
                                                  [self scheduleRide];
                                                  [self removeRideRequestView:rideRequestView];
                                                  [self updateTicketInterface];
                                                  
                                              } failure:^(NSString *errorMessage) {
                                                  [UIAlertView showWithTitle:@"Error" message:errorMessage cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                              }];
    
    
    
}


- (void) removeRideRequestView: (VCRideRequestView *) rideRequestView  {
    [UIView animateWithDuration:0.35
                     animations:^{
                         CGRect frame = rideRequestView.frame;
                         frame.origin.y =  -self.view.frame.size.height;;
                         rideRequestView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         [rideRequestView removeFromSuperview];
                     }];
}



- (void)rideRequestView:(VCRideRequestView *)rideRequestView didTapEditLocation:(CLLocationCoordinate2D)location locationName:(NSString *)locationName type:(NSInteger)type {
    
    [self placeInEditLocationMode];
    _editLocationType = type;
    
    if(_activeAnnotation != nil) {
        [self.map removeAnnotation:_activeAnnotation];
        _activeAnnotation = nil;
    }
    
    if([VCMapHelper validCoordinate:location]) {
        
        if(_activeAnnotation != nil) {
            [self.map removeAnnotation:_activeAnnotation];
            _activeAnnotation = nil;
        }
        
        
        NSString * title = @"";
        switch (_editLocationType) {
            case kHomeType:
                title = @"Home";
                _activeAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                                    coordinate:_route.home.coordinate
                                                                      andTitle:title];
                [self.map setZoom:[VCMapStyle defaultZoomForType:_editLocationType] atCoordinate:_route.home.coordinate animated:YES];
                ((RMPointAnnotation *)_activeAnnotation).image = [VCMapStyle annotationImageForType:_editLocationType];
                
                break;
            case kWorkType:
                title = @"Work";
                _activeAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                                    coordinate:_route.work.coordinate
                                                                      andTitle:title];
                [self.map setZoom:[VCMapStyle defaultZoomForType:_editLocationType] atCoordinate:_route.work.coordinate animated:YES];
                ((RMPointAnnotation *)_activeAnnotation).image = [VCMapStyle annotationImageForType:_editLocationType];
                break;
            case kPickupZoneType:
                title = @"Pickup Zone";
                _activeAnnotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                               coordinate:_route.pickupZoneCenter.coordinate
                                                                 andTitle:title];
                _activeAnnotation.userInfo = kPickupZoneAnnotationType;
                [self.map setZoom:[VCMapStyle defaultZoomForType:_editLocationType] atCoordinate:_route.pickupZoneCenter.coordinate animated:YES];
                break;
            default:
                break;
        }
        
        [self.map addAnnotation:_activeAnnotation];
        [self.map setZoom:[VCMapStyle defaultZoomForType:type] atCoordinate:location animated:YES];

    } else {
        [self zoomToCurrentLocation];
    }
    
    
    
    [UIView animateWithDuration:0.35
                     animations:^{
                         CGRect frame = rideRequestView.frame;
                         frame.origin.y =  -self.view.frame.size.height;;
                         rideRequestView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}


- (void) rideRequestViewDidCancelCommute:(VCRideRequestView *)rideRequestView{
    [UIAlertView showWithTitle:@"Cancel Trip?" message:@"Are you sure you want to cancel this trip?" cancelButtonTitle:@"No!" otherButtonTitles:@[@"Yes, Cancel this trip"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        switch(buttonIndex){
            case 1:
            {
                [self cancel];
                [self removeRideRequestView:rideRequestView];
            }
                break;
            default:
                break;
        }
    }];
}


/////////////
///////////// Location Editing Machinery
/////////////

- (void) placeInEditLocationMode: (NSInteger) editLocationType {
    _editLocationType = editLocationType;
   
    [self placeInEditLocationMode];
}


- (void) placeInEditLocationMode {
    self.navigationController.navigationBarHidden = YES;
    [self clearMap];
    
    [self.view addSubview:_locationSearchForm];
    
    [_locationSearchForm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(_locationSearchForm.frame.size.height);
    }];
    [_locationSearchForm setNeedsLayout];
    
    
    [self.view addSubview:_locationUpdateDoneButton];
    
    [_locationUpdateDoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(58);
    }];
    [_locationUpdateDoneButton setNeedsLayout];
    
}

- (void) placeInRouteMode {
    self.navigationController.navigationBarHidden = NO;
    [self clearMap];
    [_locationSearchForm removeFromSuperview];
    _locationSearchField.text = @"";
    [_locationUpdateDoneButton removeFromSuperview];
    [self updateTicketInterface];
}

- (IBAction)didTapLocationEditDone:(id)sender {
    
    if(_delegate != nil){
        [_delegate overrideUpdateLocation:_activePlacemark type:_editLocationType];
    } else {
        if(_activePlacemark != nil){
            [_rideRequestView updateLocation:_activePlacemark type:_editLocationType];
        }
        [self showRideRequestView];
        [self placeInRouteMode];
    }
    _activePlacemark = nil;

}
- (IBAction)didTapCancelLocationEdit:(id)sender {
    
    if(_delegate != nil) {
        [_delegate overrideCancelledUpdateLocation];
    } else {
        if(_inAddressLookupMode) {
            _inAddressLookupMode = NO;
            [UIView transitionWithView:self.view
                          duration:.45
                           options:0
                        animations:^{
                            _locationSearchTable.view.alpha = 1;
                        }
                        completion:^(BOOL finished) {
                            [_locationSearchTable.view removeFromSuperview];
                        }];
        } else {
            [self showRideRequestView]; // TODO: with completion:
            [self placeInRouteMode];
        }
        
    }
}


- (IBAction)didBeginEditingLocationSearchField:(id)sender {
    _inAddressLookupMode = YES;
    if(_locationSearchTable == nil){
        _locationSearchTable = [[VCLocationSearchViewController alloc] init];
        _locationSearchTable.delegate = self;
    }
    
    _locationSearchTable.tableView.alpha = 0;
    [self.view addSubview:_locationSearchTable.tableView];
    [_locationSearchTable.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top).with.offset(_locationSearchForm.frame.size.height);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [_locationSearchTable.view setNeedsLayout];
    
    
    [UIView transitionWithView:self.view
                      duration:.45
                       options:0
                    animations:^{
                        _locationSearchTable.view.alpha = 1;
                    }
                    completion:nil];
}

- (IBAction)editingDidChangeLocationSearchField:(UITextField*)sender {
    [_locationSearchTable didEditSearchText:sender.text];
}


- (void)longPressOnMap:(RMMapView *)map at:(CGPoint)point {
    
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:[map pixelToCoordinate:point].latitude longitude:[map pixelToCoordinate:point].longitude];
    
    NSString * title = _activeAnnotation.title;
    if(_activeAnnotation != nil){
        [self.map removeAnnotation:_activeAnnotation];
        _activeAnnotation = nil;
    }
    
    
    if(_editLocationType == kHomeType || _editLocationType == kWorkType ){
        _activeAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                            coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                              andTitle:title];
        ((RMPointAnnotation *)_activeAnnotation).image = [VCMapStyle annotationImageForType:_editLocationType ];
    } else if (_editLocationType == kPickupZoneType) {
        _activeAnnotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                       coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                         andTitle:title];
        _activeAnnotation.userInfo = kPickupZoneAnnotationType;
    }
    
    [self.map addAnnotation:_activeAnnotation];
    
    [self updateLocationDetails:location];
}


- (void) updateLocationDetails:(CLLocation *) location {
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        MKPlacemark * placemark = placemarks[0];
        _activePlacemark = placemark;
    }];
}

- (void)mapView:(RMMapView *)map didEndDragAnnotation:(RMAnnotation *)annotation {
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
                                                       longitude:annotation.coordinate.longitude];
    [self updateLocationDetails:location];
    
}



#pragma mark VCLocationSearchViewController
- (void) locationSearchViewController: (VCLocationSearchViewController *) locationSearchViewController didSelectLocation: (MKMapItem *) mapItem{
    _activePlacemark = mapItem.placemark;
    
    if(_activeAnnotation != nil) {
        [self.map removeAnnotation:_activeAnnotation];
        _activeAnnotation = nil;
    }
    
    
    NSString * title = @"";
    switch (_editLocationType) {
        case kHomeType:
            title = @"Home";
            break;
        case kWorkType:
            title = @"Work";
            break;
        case kPickupZoneType:
            title = @"Pickup Zone";
            break;
        default:
            break;
    }
    
    switch (_editLocationType) {
        case kHomeType:
        case kWorkType:
            _activeAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                                coordinate:_activePlacemark.coordinate
                                                                  andTitle:title];
            [self.map setZoom:[VCMapStyle defaultZoomForType:_editLocationType] atCoordinate:_activePlacemark.coordinate animated:YES];
            ((RMPointAnnotation *)_activeAnnotation).image = [VCMapStyle annotationImageForType:_editLocationType];
            break;
        case kPickupZoneType:
            _activeAnnotation = [[RMAnnotation alloc] initWithMapView:self.map
                                                           coordinate:_activePlacemark.coordinate
                                                             andTitle:title];
            _activeAnnotation.userInfo = kPickupZoneAnnotationType;
            [self.map setZoom:[VCMapStyle defaultZoomForType:_editLocationType] atCoordinate:_activePlacemark.coordinate animated:YES];
            
            break;
        default:
            break;
    }
    [self.map addAnnotation:_activeAnnotation];
    
    [_locationSearchField resignFirstResponder];
    [UIView transitionWithView:self.view
                      duration:.45
                       options:0
                    animations:^{
                        _locationSearchTable.view.alpha = 0;
                    }
                    completion:^(BOOL finished) {
                        [_locationSearchTable.view removeFromSuperview];
                    }];
    
}



#pragma mark - RMMapViewDelegate - Annotation support

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    if ([annotation.userInfo isKindOfClass:[NSString class]] &&
        [annotation.userInfo isEqualToString:kPickupZoneAnnotationType]){
        RMCircle *circle = [[RMCircle alloc] initWithView:mapView radiusInMeters:3218];
        
        // style circle's line and fill color, and width.
        circle.lineColor = [UIColor colorWithRed:.5 green:.466 blue:.733 alpha:.75];
        circle.fillColor = [UIColor colorWithRed:.5 green:.466 blue:.733 alpha:.25];
        circle.lineWidthInPixels = 5.0;
        return circle;
    } else if ([annotation.userInfo isKindOfClass:[NSString class]] &&
               [annotation.userInfo isEqualToString:kPickupPointsAnnotationType]){
        RMMarker * marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"pin"]];
        return marker;
    } else if ([annotation.title isEqualToString:@"pedestrian"]) {
        RMShape *shape = [[RMShape alloc] initWithView:mapView];
        shape.lineColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
        shape.lineWidth = 4.0;
        shape.lineDashLengths = [NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:6], nil];
        for (CLLocation *location in (NSArray *)annotation.userInfo)
            [shape addLineToCoordinate:location.coordinate];
        return shape;
    } else if ([annotation.title isEqualToString:@"driver_leg"]) {
        RMShape *shape = [[RMShape alloc] initWithView:mapView];
        shape.lineColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
        shape.lineWidth = 4.0;
        for (CLLocation *location in (NSArray *)annotation.userInfo)
            [shape addLineToCoordinate:location.coordinate];
        return shape;
    } else {
        RMShape *shape = [[RMShape alloc] initWithView:mapView];
        shape.lineColor = [UIColor colorWithRed:0.74 green: 0.25 blue: 0.15 alpha:0.8];
        shape.lineWidth = 4.0;
        for (CLLocation *location in (NSArray *)annotation.userInfo)
            [shape addLineToCoordinate:location.coordinate];
        return shape;
    }
}


////////////////
////////////////  Geo Location Updates
////////////////
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
    _lastLocation = locations[0];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationFound object:nil userInfo:@{}];
    
}

@end
