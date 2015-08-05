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
#import "VCButtonStandardStyle.h"
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

#define kCommuteStateNone 0
#define kCommuteStatePending 1
#define kCommuteStateScheduled 2

#define kNotificationLocationFound @"kNotificationLocationFound"

@interface VCTicketViewController () <RMMapViewDelegate, CLLocationManagerDelegate, VCRideRequestViewDelegate, VCLocationSearchViewControllerDelegate, VCRiderTicketViewDelegate, VCDriverTicketViewDelegate>

// Model
@property(strong, nonatomic) Route * route;

// Map
@property (strong, nonatomic) RMMapView * map;
@property (strong, nonatomic) RMAnnotation * routeOverlay;
@property (strong, nonatomic) CLGeocoder * geocoder;
@property (nonatomic) MBRegion *rideRegion;
@property (strong, nonatomic) RMPointAnnotation * originAnnotation;
@property (strong, nonatomic) RMPointAnnotation * destinationAnnotation;
@property (strong, nonatomic) RMPointAnnotation * meetingPointAnnotation;
@property (strong, nonatomic) RMPointAnnotation * dropOffPointAnnotation;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) CLLocation * lastLocation;
@property (nonatomic) BOOL initialZoomComplete;

- (void) clearMap;
- (void) clearRoute;

- (void) resetInterface;
- (void) zoomToCurrentLocation;


- (IBAction)didTapCurrentLocationButton:(id)sender;


- (IBAction)didTapTestingButton:(id)sender;



// Ride Details
@property (strong, nonatomic) VCRiderTicketView * riderTicketHUD;
@property (strong, nonatomic) VCDriverTicketView * driverTicketHUD;


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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startLocationUpdates];
    
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
    
    [self loadCommuteSettings];
    
    if(!_appeared){
        
        RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"snacks.c66a5d06"];
        self.map = [[RMMapView alloc] initWithFrame:self.view.frame andTilesource:tileSource];
        self.map.adjustTilesForRetinaDisplay = YES;
        self.map.delegate = self;
        [self.view insertSubview:self.map atIndex:0];
        self.map.userTrackingMode = RMUserTrackingModeNone;
        self.map.showsUserLocation = YES;
        
        _appeared = YES;
        
        [self updateTicketInterface];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripFulfilled:) name:kNotificationTypeTripFulfilled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tripUnfulfilled:) name:kNotificationTypeTripUnfulfilled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareCompleted:) name:kNotificationTypeFareComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareCancelledByDriver:) name:kPushTypeFareCancelledByDriver object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareCancelledByRider:) name:kPushTypeFareCancelledByRider object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFound:) name:kNotificationLocationFound object:nil];
}

- (void) viewWillDisppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//////////////
////////////// Map and Routes
//////////////


- (void) showDefaultRoute {
    if([_route routeCoordinateSettingsValid]){
        if([_route hasCachedRoute]){
            [self showRoute:_route.polyline withRegion:_route.region];
        } else {
            [self zoomToCurrentLocation];
            [self updateDefaultRoute];
        }
    } else {
        if(_routeOverlay != nil){
            [_map removeAnnotation:_routeOverlay];
        }
        [self zoomToCurrentLocation];
    }
}


- (void) updateDefaultRoute {
    
    [VCMapQuestRouting route:CLLocationCoordinate2DMake(_route.home.coordinate.latitude, _route.home.coordinate.longitude)
                          to:CLLocationCoordinate2DMake(_route.work.coordinate.latitude, _route.work.coordinate.longitude)
                     success:^(NSArray *polyline, MBRegion *region) {
                         
                         _route.polyline = polyline;
                         _route.region = region;
                         [[VCCommuteManager instance] storeRoute:polyline withRegion:region];
                         [self showRoute:polyline withRegion:region];
                         
                     } failure:^{
                         NSLog(@"%@", @"Error talking with MapQuest routing API");
                     }];
    
}

- (void) showTicketRoute {
    if([_ticket hasCachedRoute]){
        [self showRoute:_ticket.polyline withRegion:_ticket.region];
    } else {
        [self updateTicketRoute];
    }
    
}

- (void) updateTicketRoute {
    
    [VCMapQuestRouting route:CLLocationCoordinate2DMake([_ticket.meetingPointLatitude doubleValue], [_ticket.meetingPointLongitude doubleValue])
                          to:CLLocationCoordinate2DMake([_ticket.dropOffPointLatitude doubleValue], [_ticket.dropOffPointLatitude doubleValue])
                     success:^(NSArray *polyline, MBRegion *region) {
                         
                         _ticket.polyline = polyline;
                         _ticket.region = region;
                         [self showRoute:polyline withRegion:region];
                         
                     } failure:^{
                         NSLog(@"%@", @"Error talking with MapQuest routing API");
                     }];
    
}

- (void) showRoute:(NSArray*) polyline withRegion:(MBRegion * ) region {
    if (_routeOverlay != nil) {
        [_map removeAnnotation:_routeOverlay];
    }
    
    if(region.topLocation.latitude == 0 || region.bottomLocation.longitude == 0){
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
    
    NSLog(@"Zoom To Region");
    [_map zoomWithLatitudeLongitudeBoundsSouthWest:[VCMapHelper paddedNELocation:region.topLocation]
                                         northEast:[VCMapHelper paddedSWLocation:region.bottomLocation]
                                          animated:YES];
    
  
}


- (void) clearRoute {
    if (_routeOverlay != nil) {
        [self.map removeAnnotation:_routeOverlay];
    }
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


///////////////////
///////////////////   Handle State Updates
///////////////////

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
}

- (void) showHome{
    //Replaced homeActionView with editCommuteButton for this version
    
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
    
    [_rideRequestView updateWithRoute:_route];
    [self showRideRequestView];
    [_rideRequestView setEditable:editable];
    
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
    UIBarButtonItem *buttonItem;
    switch(state){
        case kCommuteStateNone:
        {
            buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Schedule Rides" style:UIBarButtonItemStylePlain target:self action:@selector(didTapScheduleMenuButton:)];
            break;
        }
        case kCommuteStatePending:
        {
            buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Commute Pending" style:UIBarButtonItemStylePlain target:self action:@selector(didTapReviewScheduleMenuButton:)];
            break;
        }
        case kCommuteStateScheduled:
        {
            buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel Ride" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancel:)];
            break;
        }
        default:
        {
            buttonItem = nil;
            break;
        }
            
    }
    if(buttonItem != nil){
        self.navigationItem.rightBarButtonItem = buttonItem;
        self.navigationItem.rightBarButtonItem.tintColor = _barButtonItemColor;
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
        }
        
    } else if([@[kCreatedState, kRequestedState] containsObject:_ticket.state]){
        
        [self setRightButtonForState:kCommuteStatePending];
        [self addOriginAnnotation: [_ticket originLocation] ];
        [self addDestinationAnnotation: [_ticket destinationLocation]];
        [self showDefaultRoute];
        
    } else if([_ticket.state isEqualToString:kCommuteSchedulerFailedState]) {
        [self setRightButtonForState:kCommuteStateNone];
        
    } else if([_ticket.state isEqualToString:kScheduledState]){
        [self setRightButtonForState:kCommuteStateScheduled];
        
        [self updateMapForTicket:_ticket];
        
        // show the HUD interface
        if([_ticket.driving boolValue] ) {
            [self showDriverTicketHUD];
        } else {
            [self showRiderTicketHUD];
        }
        
        
    }
    
}

- (void) updateMapForTicket:(Ticket *) ticket {
    [self addMeetingPointAnnotation: [ticket meetingPointLocation]];
    [self addDropOffPointAnnotation: [ticket dropOffPointLocation]];
    [self.map selectAnnotation:_meetingPointAnnotation animated:YES];
    
    [self showTicketRoute];
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

- (void) resetInterfaceToHome {
    [self clearMap];
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
    [self clearRoute];
}




- (void) showRiderTicketHUD {
    VCRiderTicketView * view = [WRUtilities getViewFromNib:@"VCRiderTicketView" class:[VCRiderTicketView class]];
    view.delegate = self;
    
    CGRect frame = view.frame;
    frame.origin.x = 0;
    frame.origin.y = 481;
    frame.size.width = self.view.frame.size.width;
    view.frame = frame;
    
    [self.view addSubview:view];
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         // final placement
                         CGRect frame = view.frame;
                         frame.origin.y = 380;
                         view.frame = frame;
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (void) showDriverTicketHUD {
    VCDriverTicketView * view = [WRUtilities getViewFromNib:@"VCDriverTicketView" class:[VCDriverTicketView class]];
    view.delegate = self;
    
    CGRect frame = view.frame;
    frame.origin.x = 0;
    frame.origin.y = 481;
    frame.size.width = self.view.frame.size.width;
    view.frame = frame;
    
    [self.view addSubview:view];
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         // final placement
                         CGRect frame = view.frame;
                         frame.origin.y = 380;
                         view.frame = frame;
                     } completion:^(BOOL finished) {
                         
                     }];
    
}


- (void) removeHuds {
    [_ridersPickedUpButton removeFromSuperview];
    [_rideCompleteButton removeFromSuperview];
}



- (void) didTapCancel: (id)sender {
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
    if( ![@[kCreatedState, kRequestedState] containsObject: _ticket.state]) {
        [[VCCommuteManager instance] cancelRide:_ticket success:^{
            _ticket = nil;
            [self resetInterfaceToHome];
            hud.hidden = YES;
        } failure:^{
            hud.hidden = YES;
        }];
    } else {
        // Here we are cancelling BOTH legs of the trip
        [[VCCommuteManager instance] cancelTrip:_ticket.trip_id success:^{
            _ticket = nil;
            [self resetInterfaceToHome];
            hud.hidden = YES;
        } failure:^{
            hud.hidden = YES;
        }];
    }
    
}






- (void) loadCommuteSettings {
    
    _route = [[Route alloc] init];
    _route = [[VCCommuteManager instance].route copy];
    
    if( _route.home != nil){
        [self addOriginAnnotation: _route.home ];
    }
    
    if( _route.work != nil){
        [self addDestinationAnnotation: _route.work ];
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
    _originAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                        coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                          andTitle:@"Home"];
    _originAnnotation.image = [UIImage imageNamed:@"map_pin_red"];
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
    _destinationAnnotation.image = [UIImage imageNamed:@"map_pin_green"];
    [self.map addAnnotation:_destinationAnnotation];
}

- (void)addMeetingPointAnnotation:(CLLocation *)location {
    if(self.meetingPointAnnotation != nil) {
        [self.map removeAnnotation:_meetingPointAnnotation];
        _meetingPointAnnotation = nil;
    }
    _meetingPointAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                              coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                                andTitle:@"Meeting Point"];
    _meetingPointAnnotation.image = [UIImage imageNamed:@"map_pin_red"];
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
    _dropOffPointAnnotation.image = [UIImage imageNamed:@"map_pin_green"];
    [self.map addAnnotation:_dropOffPointAnnotation];
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
                                         success:^{
                                             [hud hide:YES];
                                             
                                             // Put the waiting text in here.
                                             [self updateTicketInterface];
                                             
                                         } failure:^{
                                             [hud hide:YES];
                                             [UIAlertView showWithTitle:@"Error" message:@"There was a problem sending your request, you might want to try that again" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                         }];
    
}


- (IBAction)didTapZoomToRideBounds:(id)sender {
    if (_ticket != nil) {
        [self.map zoomWithLatitudeLongitudeBoundsSouthWest:self.rideRegion.topLocation northEast:self.rideRegion.bottomLocation animated:NO];
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
    [self removeRideRequestView: rideRequestView];
    _route = [route copy];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[VCCommuteManager instance] storeCommuterSettings:_route
                                               success:^{
                                                   [hud hide:YES];
                                                   [self updateDefaultRoute];
                                                   
                                               } failure:^(NSString *errorMessage) {
                                                   [hud hide:YES];
                                                   
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
    [UIView animateWithDuration:0.35
                     animations:^{
                         CGRect frame = rideRequestView.frame;
                         frame.origin.y =  -self.view.frame.size.height;;
                         rideRequestView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)rideRequestView:(VCRideRequestView *)rideRequestView didTapScheduleCommute:(Route *)route {
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
    }];
    [_locationUpdateDoneButton setNeedsLayout];
    
}

- (void) placeInRouteMode {
    self.navigationController.navigationBarHidden = NO;
    [_locationSearchForm removeFromSuperview];
    _locationSearchField.text = @"";
    [_locationUpdateDoneButton removeFromSuperview];
}

- (IBAction)didTapLocationEditDone:(id)sender {
    
    [_rideRequestView updateLocation:_activePlacemark type:_editLocationType];
    [self showRideRequestView]; // TODO: with completion:
    [self placeInRouteMode];
    
}
- (IBAction)didTapCancelLocationEdit:(id)sender {
    [self showRideRequestView]; // TODO: with completion:
    [self placeInRouteMode];
}


- (IBAction)didBeginEditingLocationSearchField:(id)sender {
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
    
    if(_editLocationType == kHomeType) {
        if(_originAnnotation != nil) {
            [self.map removeAnnotation:_originAnnotation];
            _originAnnotation = nil;
        }
        _originAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                            coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                              andTitle:@"Home"];
        [self.map addAnnotation:_originAnnotation];
        
    } else if (_editLocationType == kWorkType) {
        if(_destinationAnnotation != nil) {
            [self.map removeAnnotation:_destinationAnnotation];
            _destinationAnnotation = nil;
        }
        _destinationAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                                 coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                                                                   andTitle:@"Work"];
        [self.map addAnnotation:_destinationAnnotation];
    }
    
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
    
    // Add the point to the map
    if(_editLocationType == kHomeType) {
        if(_originAnnotation != nil) {
            [self.map removeAnnotation:_originAnnotation];
            _originAnnotation = nil;
        }
        
        _originAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                            coordinate:_activePlacemark.coordinate
                                                              andTitle:@"Home"];
        [self.map addAnnotation:_originAnnotation];
        
    } else if (_editLocationType == kWorkType) {
        if(_destinationAnnotation != nil) {
            [self.map removeAnnotation:_destinationAnnotation];
            _destinationAnnotation = nil;
        }
        _destinationAnnotation = [[RMPointAnnotation alloc] initWithMapView:self.map
                                                                 coordinate:_activePlacemark.coordinate
                                                                   andTitle:@"Work"];
        [self.map addAnnotation:_destinationAnnotation];
    }
    
    [self.map setZoom:5 atCoordinate:_activePlacemark.coordinate animated:YES];
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
    
    if ([annotation.title isEqualToString:@"pedestrian"]) {
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
        shape.lineColor = [UIColor colorWithRed:17.0f / 256.0f green: 119.0f / 256.0f blue: 45.0f / 256.0f alpha:.7];
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
