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
#import "VCUserState.h"
#import "VCFareDriverAssignment.h"
#import "VCDriverApi.h"
#import "VCFare.h"
#import "VCUtilities.h"
#import "VCLabelBold.h"


@interface VCDriverHomeViewController ()
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

@property (strong, nonatomic) IBOutlet UIView *commuterCallHud;
@property (strong, nonatomic) IBOutlet VCButtonFontBold *riderSelectButtonOne;
@property (strong, nonatomic) IBOutlet VCButtonFontBold *riderSelectButtonTwo;
@property (strong, nonatomic) IBOutlet VCButtonFontBold *riderSelectButtonThree;
@property (strong, nonatomic) IBOutlet UIButton *callButtonCommuter;

- (IBAction)didTapRiderSelect:(id)sender;

- (IBAction)didTapCommuterCallButton:(id)sender;




//On Demand Call HUD

@property (strong, nonatomic) IBOutlet UIView *onDemandCallHud;
@property (weak, nonatomic) IBOutlet UIButton *callButtonOnDemand;
@property (weak, nonatomic) IBOutlet VCLabelBold *riderNameLabel;

- (IBAction)didTapOnDemandCallButton:(id)sender;


@end

@implementation VCDriverHomeViewController

- (void) setRide:(Fare *)ride {
    _ride = ride;
    self.transit = ride;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideOfferInvokedNotification:) name:@"ride_offer_invoked" object:[VCDialogs instance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideInvoked:) name:@"driver_ride_invoked" object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetButtons];
    if(self.transit != nil){
        [self showRide];
    }

}


- (void) rideOfferInvokedNotification:(NSNotification *)notification{
    [self resetButtons];
    NSDictionary * info = [notification userInfo];
    NSNumber * rideId = [info objectForKey: @"ride_id"];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Fare"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ride_id = %@", rideId];
    [request setPredicate:predicate];
    NSError * error;
    NSArray * results = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
    if(results == nil){
        [WRUtilities criticalError:error];
        return;
    }
    self.ride = results.firstObject;
    [self clearMap];
    [self showRide];
    [self showAcceptOrDeclineRideInterface];
}

- (void) rideInvoked:(NSNotification *) notification {
    Fare * ride = notification.object;
    self.ride = ride;
    [self clearMap];
    [self showRide];
    [self showPickupInterface];
}

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
    
    if(_commuterCallHud.superview == nil) {
        CGRect frame = _commuterCallHud.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.frame.size.height - 164;
        _commuterCallHud.frame = frame;
        [self.view addSubview:self.commuterCallHud];
    }
    
   

}

- (void) showRideInProgressInterface {
    [self resetButtons];
    _cancelRideButton.hidden = NO;
    _rideCompletedButton.hidden = NO;
    self.locationTypeLabel.text = @"Drop Off Location";
    self.addressLabel.text = self.transit.dropOffPointPlaceName;
    [self addLocationHudIfNotDisplayed];

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
    
    self.title = self.ride.routeDescription;
    
    [self showSuggestedRoute];
    
    [self annotateMeetingPoint:[[CLLocation alloc] initWithLatitude:[self.ride.meetingPointLatitude doubleValue]
                                                          longitude:[self.ride.meetingPointLongitude doubleValue]]
               andDropOffPoint:[[CLLocation alloc] initWithLatitude:[self.ride.dropOffPointLatitude doubleValue]
                                                          longitude:[self.ride.dropOffPointLongitude doubleValue]]];
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
                          [VCUserState instance].driveProcessState = kUserStateIdle;
                          if (buttonIndex != 0){
                              // Launch the payments page for this ride
                          }
                          
                      }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) resetInterface {
    [self resetButtons];
    [self clearMap];
}

- (IBAction)didTapAccept:(id)sender {
    VCFareDriverAssignment * assignment = [[VCFareDriverAssignment alloc] init];
    assignment.rideId = self.transit.ride_id;
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Accepting Ride";
    CLS_LOG(@"%@", @"API_POST_RIDE_ACCEPTED");
    [[RKObjectManager sharedManager] postObject:assignment path:API_POST_RIDE_ACCEPTED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        // TODO at this point we assume ride is confirmed
        // but at a later date we may add a step that waits for the rider to confirm that
        // they know about the ride being scheduled (handshake)
        [VCUserState instance].driveProcessState = kUserStateRideAccepted;
        [VCUserState instance].underwayRideId = self.transit.ride_id;
        
        [((Fare *) self.transit) markOfferAsAccepted];
        
        [hud hide:YES];
        [self showPickupInterface];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // network error..
        
        if(operation.HTTPRequestOperation.response.statusCode == 403){
            // already accepted by another driver
            [((Fare *) self.transit) markOfferAsClosed];

            [UIAlertView showWithTitle:@"Ride no longer available!" message:@"Unfortunately another driver beat you to this ride!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {

                [self resetInterface];
                [[VCDialogs instance] offerNextRideToDriver];
            }];
        }
        
        [hud hide:YES];

    }];

}

- (IBAction)didTapDecline:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Declining";
    [VCDriverApi cancelRide:self.transit.ride_id
                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                        [self resetButtons];
                        [self clearMap];
                        [VCUserState instance].driveProcessState = @"Ride Declined";
                        [self.ride markOfferAsDeclined];
                        [VCCoreData saveContext];
                        [hud hide:YES];
                        [VCUserState instance].underwayRideId = nil;
                        [[VCDialogs instance] offerNextRideToDriver];
                        self.map.userTrackingMode = MKUserTrackingModeFollow;
                        self.map.showsUserLocation = YES;
                        [_driverLocationHud removeFromSuperview];
                        
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        [hud hide:YES];
                    }];
    
}

- (IBAction)didTapRiderPickedUp:(id)sender {
    if( [VCUserState instance].underwayRideId != nil){
        if(! [[VCUserState instance].underwayRideId isEqualToNumber: self.ride.ride_id]){
            [WRUtilities criticalErrorWithString:@"State shows another ride is still underway"];
        }
        [VCUserState instance].underwayRideId = self.ride.ride_id;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Notifying Server";
    VCFareDriverAssignment * rideIdentity = [[VCFareDriverAssignment alloc] init];
    rideIdentity.rideId = _ride.ride_id;
    [VCUserState instance].underwayRideId = _ride.ride_id;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDE_PICKUP parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self showRideInProgressInterface];
                                            [VCUserState instance].driveProcessState = kUserStateRideStarted;
                                            [hud hide:YES];
                                            
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [hud hide:YES];

                                        }];
}

- (IBAction)didTapCancelRide:(id)sender {
    // Send cancel request to server
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cancelling";
    VCFareDriverAssignment * rideIdentity = [[VCFareDriverAssignment alloc] init];
    rideIdentity.rideId = _ride.ride_id;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_DRIVER_CANCELLED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [UIAlertView showWithTitle:@"Cancelled Ride" message:@"The ride was successfully cancelled" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                            [self resetButtons];
                                            [self clearMap];
                                            [VCUserState instance].driveProcessState = kUserStateIdle;
                                            [hud hide:YES];
                                            [VCUserState instance].underwayRideId = nil;

                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            // TODO: need to cache this action and try again later
                                            // how else will the server be notified ? could be a bad edge case
                                            [hud hide:YES];
                                        }];
    
}


- (IBAction)didTapRideCompleted:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Notifying Server";
    VCFareDriverAssignment * rideIdentity = [[VCFareDriverAssignment alloc] init];  // TODO objects like this can be generated from
    // global state of the app, i.e. in another method
    rideIdentity.rideId = [VCUserState instance].underwayRideId;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDE_ARRIVED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [VCUserState instance].driveProcessState = kUserStateRideCompleted;
                                            [self showRideCompletedInterface];
                                            VCFare * fare = mappingResult.firstObject;
                                            [self showReceipt:fare.driverEarnings];
                                            [hud hide:YES];
                                            [VCUserState instance].underwayRideId = nil;

                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [hud hide:YES];

                                        }];
}

- (IBAction)didTapZoomToRideBounds:(id)sender {
    [self.map setRegion:self.rideRegion animated:YES];
}

- (IBAction)didTapCurrentLocation:(id)sender {
    [self.map setCenterCoordinate:self.map.userLocation.coordinate animated:YES];
}
- (IBAction)didTapRiderSelect:(id)sender {
    UIButton * button = (UIButton*)sender;
    if (button.selected){
        return;
    }
    _riderSelectButtonOne.selected = NO;
    _riderSelectButtonTwo.selected = NO;
    _riderSelectButtonThree.selected = NO;
    button.selected = YES;

}


- (IBAction)didTapCommuterCallButton:(id)sender {
}
- (IBAction)didTapOnDemandCallButton:(id)sender {
}
@end
