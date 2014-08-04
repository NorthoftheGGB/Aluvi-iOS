//
//  VCDriverHomeViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverHomeViewController.h"
#import <MapKit/MapKit.h>
#import <MBProgressHUD.h>
#import <Crashlytics/Crashlytics.h>
#import "VCLabel.h"
#import "VCDialogs.h"
#import "VCButtonFontBold.h"
#import "VCUserStateManager.h"
#import "VCFareDriverAssignment.h"
#import "VCDriverApi.h"
#import "VCFare.h"
#import "VCUtilities.h"
#import "VCLabelBold.h"
#import "VCDriverHUD.h"
#import "VCPushApi.h"


@interface VCDriverHomeViewController () <VCDriverHUDDelegate>

@property (weak, nonatomic) IBOutlet VCButtonFontBold *acceptButton;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *declineButton;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *riderPickedUpButton;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *cancelRideButton;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *rideCompletedButton;

- (IBAction)didTapAccept:(id)sender;
- (IBAction)didTapDecline:(id)sender;
- (IBAction)didTapRiderPickedUp:(id)sender;
- (IBAction)didTapCancelRide:(id)sender;
- (IBAction)didTapRideCompleted:(id)sender;

//Driver Location HUD

@property (strong, nonatomic) IBOutlet UIView *driverLocationHud;

- (IBAction)didTapZoomToRideBounds:(id)sender;
- (IBAction)didTapCurrentLocation:(id)sender;

@property (strong, nonatomic) IBOutlet VCLabel *locationTypeLabel;
@property (strong, nonatomic) IBOutlet VCLabel *addressLabel;

//Commuter Call HUD
@property (strong, nonatomic) IBOutlet VCDriverHUD *commuterCallHud;

//On Demand Call HUD

@property (strong, nonatomic) IBOutlet UIView *onDemandCallHud;
@property (weak, nonatomic) IBOutlet UIButton *callButtonOnDemand;
@property (weak, nonatomic) IBOutlet VCLabelBold *riderNameLabel;

- (IBAction)didTapOnDemandCallButton:(id)sender;


@end

@implementation VCDriverHomeViewController

- (void) setFare:(Fare *)ride {
    _fare = ride;
    self.transit = ride;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareOfferInvokedNotification:) name:@"fare_offer_invoked" object:[VCDialogs instance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideInvoked:) name:@"driver_ride_invoked" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideCancelledByRider:) name:kPushTypeFareCancelledByRider object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareOfferClosed:) name:kPushTypeRideOfferClosed object:nil];

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetButtons];
    if(self.transit != nil){
        [self showRide];
    }

    _commuterCallHud.delegate = self;
    [_commuterCallHud setRiderNames:@[@"Ricky Horsepow", @"Klandish Filnao"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// Notification Handlers
- (void) fareOfferInvokedNotification:(NSNotification *)notification{
    [self resetButtons];
    NSDictionary * info = [notification userInfo];
    NSNumber * fareId = [info objectForKey: @"fare_id"];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Fare"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fare_id = %@", fareId];
    [request setPredicate:predicate];
    NSError * error;
    NSArray * results = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
    if(results == nil){
        [WRUtilities criticalError:error];
        return;
    }
    self.fare = results.firstObject;
    [self clearMap];
    [self showRide];
    [self showAcceptOrDeclineRideInterface];
}

- (void) fareOfferClosed: (NSNotification *) notification {
    NSNumber * fareId = notification.object;
    if(_fare != nil && [fareId isEqualToNumber:_fare.fare_id]){  //TODO should be fare_id fareId
        [self resetInterface];
        [UIAlertView showWithTitle:@"Offer Closed" message:@"This ride offer has closed" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [[VCDialogs instance] offerNextFareToDriver];
        }];
    }

}

- (void) rideInvoked:(NSNotification *) notification {
    Fare * ride = notification.object;
    self.fare = ride;
    [self clearMap];
    [self showRide];
    [self showPickupInterface];
}

- (void) rideCancelledByRider: (NSNotification *) notification {
    NSNumber * fareId = notification.object;
    if(_fare != nil && [fareId isEqualToNumber:_fare.fare_id]){
        [self resetInterface];
    }
}


// Interface Modes
- (void) resetButtons {
    _acceptButton.hidden = YES;
    _declineButton.hidden = YES;
    _riderPickedUpButton.hidden = YES;
    _cancelRideButton.hidden = YES;
    _rideCompletedButton.hidden = YES;
}

- (void) showAcceptOrDeclineRideInterface {
    [self resetButtons];
    _acceptButton.hidden = NO;
    _declineButton.hidden = NO;
    self.locationTypeLabel.text = @"Pickup Location";
    self.addressLabel.text = self.transit.meetingPointPlaceName;
    [self addLocationHudIfNotDisplayed];
}

- (void) showPickupInterface {
    [self resetButtons];
    _riderPickedUpButton.hidden = NO;
    _cancelRideButton.hidden = NO;
    self.locationTypeLabel.text = @"Pickup Location";
    self.addressLabel.text = self.transit.meetingPointPlaceName;
    [self addLocationHudIfNotDisplayed];
    
    [self showCommuterCallHudIfNotDisplayed];
    
}

- (void) showRideInProgressInterface {
    [self resetButtons];
    _cancelRideButton.hidden = NO;
    _rideCompletedButton.hidden = NO;
    self.locationTypeLabel.text = @"Drop Off Location";
    self.addressLabel.text = self.transit.dropOffPointPlaceName;
    [self addLocationHudIfNotDisplayed];
}

- (void) showCommuterCallHudIfNotDisplayed {
    if(_commuterCallHud.superview == nil) {
        CGRect frame = _commuterCallHud.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.frame.size.height - 164;
        _commuterCallHud.frame = frame;
        [self.view addSubview:self.commuterCallHud];
        
        // Populate with rider names
    }
}

- (void) hideCommuterCallHud {
    [_commuterCallHud removeFromSuperview];
}

- (void) addLocationHudIfNotDisplayed {
    if(_driverLocationHud.superview == nil) {
        CGRect frame = _driverLocationHud.frame;
        frame.origin.x = 0;
        frame.origin.y = 64;
        _driverLocationHud.frame = frame;
        [self.view addSubview:self.driverLocationHud];
    }
}

- (void) showRide{
    
    self.title = self.fare.routeDescription;
    
    [self showSuggestedRoute];
    
    [self annotateMeetingPoint:[[CLLocation alloc] initWithLatitude:[self.fare.meetingPointLatitude doubleValue]
                                                          longitude:[self.fare.meetingPointLongitude doubleValue]]
               andDropOffPoint:[[CLLocation alloc] initWithLatitude:[self.fare.dropOffPointLatitude doubleValue]
                                                          longitude:[self.fare.dropOffPointLongitude doubleValue]]];
    self.title = [self.transit routeDescription];
}

- (void) showRideCompletedInterface {
    [_driverLocationHud removeFromSuperview];
    [self resetButtons];
    [self clearMap];
}

- (void) showReceipt: (NSNumber *) earnings {

    [UIAlertView showWithTitle:@"Receipt"
                       message:[NSString stringWithFormat:@"Thanks for driving.  You earned %@ on this ride.",
                                [VCUtilities formatCurrencyFromCents:earnings]]
             cancelButtonTitle:@"OK"
             otherButtonTitles:@[@"Detailed Receipt"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [VCUserStateManager instance].driveProcessState = kUserStateIdle;
                          if (buttonIndex != 0){
                              // Launch the payments page for this ride
                          }
                          
                      }];
}

- (void) resetInterface {
    [self resetButtons];
    [self clearMap];
    [self hideCommuterCallHud];
}

- (IBAction)didTapAccept:(id)sender {
    
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Accepting Ride";
    CLS_LOG(@"%@", @"API_POST_RIDE_ACCEPTED");
    [VCDriverApi acceptFare:self.transit.fare_id success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        // TODO at this point we assume ride is confirmed
        // but at a later date we may add a step that waits for the rider to confirm that
        // they know about the ride being scheduled (handshake)
        [VCUserStateManager instance].driveProcessState = kUserStateRideAccepted;
        [VCUserStateManager instance].underwayFareId = self.transit.fare_id;
        
        [((Fare *) self.transit) markOfferAsAccepted];
        
        [hud hide:YES];
        [self showPickupInterface];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        if(operation.HTTPRequestOperation.response.statusCode == 403){
            // already accepted by another driver
            [((Fare *) self.transit) markOfferAsClosed];
            
            [UIAlertView showWithTitle:@"Ride no longer available!" message:@"Unfortunately another driver beat you to this ride!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                [self resetInterface];
                [[VCDialogs instance] offerNextFareToDriver];
            }];
        }
        
        [hud hide:YES];

    }];
    
}

- (IBAction)didTapDecline:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Declining";
    [VCDriverApi declineFare:self.transit.fare_id
                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                        [self resetButtons];
                        [self clearMap];
                        [VCUserStateManager instance].driveProcessState = @"Ride Declined";
                        [self.fare markOfferAsDeclined];
                        [VCCoreData saveContext];
                        
                        self.map.userTrackingMode = MKUserTrackingModeFollow;
                        self.map.showsUserLocation = YES;
                        [_driverLocationHud removeFromSuperview];
                        [hud hide:YES];
                        
                        [VCUserStateManager instance].underwayFareId = nil;
                        [[VCDialogs instance] offerNextFareToDriver];

                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        [hud hide:YES];
                    }];
    
}

- (IBAction)didTapRiderPickedUp:(id)sender {
    if( [VCUserStateManager instance].underwayFareId != nil){
        if(! [[VCUserStateManager instance].underwayFareId isEqualToNumber: self.fare.fare_id]){
            [WRUtilities criticalErrorWithString:@"State shows another ride is still underway"];
        }
        [VCUserStateManager instance].underwayFareId = self.fare.fare_id;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Notifying Server";
    
    [VCUserStateManager instance].underwayFareId = _fare.fare_id;
    [VCDriverApi ridersPickedUp:_fare.fare_id
                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self showRideInProgressInterface];
                                            [VCUserStateManager instance].driveProcessState = kUserStateRideStarted;
                                            [hud hide:YES];
                                            
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [hud hide:YES];

                                        }];
}

- (IBAction)didTapCancelRide:(id)sender {
    // Send cancel request to server
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cancelling";
    [VCDriverApi fareCancelledByDriver:self.transit.fare_id
                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [UIAlertView showWithTitle:@"Cancelled Ride" message:@"The ride was successfully cancelled" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                            [self resetButtons];
                                            [self clearMap];
                                            self.fare = nil;
                                            [hud hide:YES];
                                            
                                            [VCUserStateManager instance].driveProcessState = kUserStateIdle;
                                            [VCUserStateManager instance].underwayFareId = nil;
                                            
                                            [self hideCommuterCallHud];

                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            // TODO: need to cache this action and try again later
                                            // how else will the server be notified ? could be a bad edge case
                                            [hud hide:YES];
                                        }];
    
}


- (IBAction)didTapRideCompleted:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Notifying Server";
   
    [VCDriverApi fareCompleted:self.transit.fare_id
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [VCUserStateManager instance].driveProcessState = kUserStateRideCompleted;
                                            [self showRideCompletedInterface];
                                            VCFare * fare = mappingResult.firstObject;
                                            [self showReceipt:fare.driverEarnings];
                                            [VCUserStateManager instance].underwayFareId = nil;
                                            [hud hide:YES];
                                            
                                            [self hideCommuterCallHud];

                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [hud hide:YES];

                                        }];
}

- (IBAction)didTapZoomToRideBounds:(id)sender {
    if (self.fare != nil) {
        [self.map setRegion:self.rideRegion animated:YES];
    }
}

- (IBAction)didTapCurrentLocation:(id)sender {
    [self.map setCenterCoordinate:self.map.userLocation.coordinate animated:YES];
}


- (IBAction)didTapOnDemandCallButton:(id)sender {
}

#pragma mark -- VCDriverHUDDelegate

- (void)didRequestCallForIndex:(NSInteger)index {
    // Make the call!!
}

@end
