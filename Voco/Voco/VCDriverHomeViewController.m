//
//  VCDriverHomeViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverHomeViewController.h"
#import "VCLabel.h"
#import <MapKit/MapKit.h>
#import "VCDialogs.h"
#import "VCButtonFontBold.h"
#import "VCUserState.h"
#import "VCRideDriverAssignment.h"
#import "VCDriverApi.h"


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



@end

@implementation VCDriverHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideOfferInvokedNotification:) name:@"ride_offer_invoked" object:[VCDialogs instance]];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.transport != nil){
        [self showRide];
    }
    
}

- (void) rideOfferInvokedNotification:(NSNotification *)notification{
    [self resetButtons];
    NSDictionary * info = [notification userInfo];
    NSNumber * rideId = [info objectForKey: @"ride_id"];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Drive"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ride_id = %@", rideId];
    [request setPredicate:predicate];
    NSError * error;
    NSArray * results = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
    if(results == nil){
        [WRUtilities criticalError:error];
        return;
    }
    self.transport = results.firstObject;
    [self clearMap];
    [self showRide];
    [self showAcceptOrDeclineRideInterface];
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
}

- (void) showPickupInterface {
    [self resetButtons];
    _riderPickedUpButton.hidden = NO;
    _cancelRideButton.hidden = NO;
    self.locationTypeLabel.text = @"Pickup Location";
    self.addressLabel.text = self.transport.meetingPointPlaceName;
    [self addLocationHudIfNotDisplayed];

}

- (void) showRideInProgressInterface {
    [self resetButtons];
    _cancelRideButton.hidden = NO;
    _rideCompletedButton.hidden = NO;
    self.locationTypeLabel.text = @"Drop Off Location";
    self.addressLabel.text = self.transport.destinationPlaceName;
    [self addLocationHudIfNotDisplayed];

}

- (void) addLocationHudIfNotDisplayed {
    if(_driverLocationHud.superview == nil) {
        CGRect frame = _driverLocationHud.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        _driverLocationHud.frame = frame;
        [self.view addSubview:self.driverLocationHud];
    }
}

- (void) showRide{
    [self showSuggestedRoute];
    [self showRideLocations];
    self.title = [self.transport routeDescription];
}

- (void) showRideCompletedInterface {
    [_driverLocationHud removeFromSuperview];
    [self showReceipt];
}

- (void) showReceipt {
    [UIAlertView showWithTitle:@"Receipt"
                       message:@"This is a placeholder for the receipt view.  Thanks for driving!"
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [VCUserState instance].driveProcessState = kUserStateIdle;
                          
                      }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)didTapAccept:(id)sender {
    VCRideDriverAssignment * assignment = [[VCRideDriverAssignment alloc] init];
    assignment.rideId = self.transport.ride_id;
    
    CLS_LOG(@"%@", @"API_POST_RIDE_ACCEPTED");
    [[RKObjectManager sharedManager] postObject:assignment path:API_POST_RIDE_ACCEPTED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        // TODO at this point we assume ride is confirmed
        // but at a later date we may add a step that waits for the rider to confirm that
        // they know about the ride being scheduled (handshake)
        [VCUserState instance].driveProcessState = kUserStateRideAccepted;
        [VCUserState instance].underwayRideId = self.transport.ride_id;
        
        
        [((Drive *) self.transport) markOfferAsAccepted];
        
                
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // network error..
        
        if(operation.HTTPRequestOperation.response.statusCode == 403){
            // already accepted by another driver
            [((Drive *) self.transport) markOfferAsClosed];

            [UIAlertView showWithTitle:@"Ride no longer available!" message:@"Unfortunately another driver beat you to this ride!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {

                [[VCDialogs instance] offerNextRideToDriver];
            }];
        }
    }];

}

- (IBAction)didTapDecline:(id)sender {
    [VCDriverApi cancelRide:self.transport.ride_id
                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                        [VCUserState instance].driveProcessState = @"Ride Declined";
                        [((Drive *) self.transport) markOfferAsDeclined];
                        [VCCoreData saveContext];
                        [[VCDialogs instance] offerNextRideToDriver];
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        
                    }];
    
}

- (IBAction)didTapRiderPickedUp:(id)sender {
    VCRideDriverAssignment * rideIdentity = [[VCRideDriverAssignment alloc] init];
    rideIdentity.rideId = [VCUserState instance].underwayRideId;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDE_PICKUP parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self showRideInProgressInterface];
                                            [VCUserState instance].driveProcessState = kUserStateRideStarted;
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                        }];
}

- (IBAction)didTapCancelRide:(id)sender {
    // Send cancel request to server
    VCRideDriverAssignment * rideIdentity = [[VCRideDriverAssignment alloc] init];
    rideIdentity.rideId = [VCUserState instance].underwayRideId;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_DRIVER_CANCELLED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [UIAlertView showWithTitle:@"Cancelled Ride" message:@"The ride was successfully cancelled" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                            [self resetButtons];
                                            [VCUserState instance].driveProcessState = kUserStateIdle;
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            // TODO: need to cache this action and try again later
                                            // how else will the server be notified ? could be a bad edge case
                                        }];
    
}

- (IBAction)didTapRideCompleted:(id)sender {
    VCRideDriverAssignment * rideIdentity = [[VCRideDriverAssignment alloc] init];  // TODO objects like this can be generated from
    // global state of the app, i.e. in another method
    rideIdentity.rideId = [VCUserState instance].underwayRideId;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDE_ARRIVED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [VCUserState instance].driveProcessState = kUserStateRideCompleted;
                                            [self showRideCompletedInterface];
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                        }];
}

- (IBAction)didTapZoomToRideBounds:(id)sender {
    [self.map setRegion:self.rideRegion];
}

- (IBAction)didTapCurrentLocation:(id)sender {
    [self.map setCenterCoordinate:self.map.userLocation.coordinate];
}
@end
