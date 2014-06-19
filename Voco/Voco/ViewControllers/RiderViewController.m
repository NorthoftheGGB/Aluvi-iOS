//
//  RiderViewController.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "RiderViewController.h"
#import <RestKit.h>
#import <Reachability.h>
#import "VCApi.h"
#import "VCRideRequest.h"
#import "VCRideRequestCreated.h"
#import "WRUtilities.h"
#import "DriverViewController.h"
#import "VCDevice.h"
#import "VCUserState.h"
#import "VCRideIdentity.h"

static void * XXContext = &XXContext;

@interface RiderViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;

- (IBAction)didTapRequestButton:(id)sender;
- (IBAction)didTapCancelRequestButton:(id)sender;
- (IBAction)didTapDriverModeButton:(id)sender;
- (IBAction)didTapCancelRideButton:(id)sender;

@end

@implementation RiderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _stateLabel.text = @"Idle";
    
    [[VCUserState instance] addObserver:self forKeyPath:@"rideProcessState" options:NSKeyValueObservingOptionNew context:XXContext];
    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    [[VCUserState instance] removeObserver:self forKeyPath:@"rideProcessState"];
}

- (void)dealloc {
    [[VCUserState instance] removeObserver:self forKeyPath:@"rideProcessState"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    _stateLabel.text = [change objectForKey:NSKeyValueChangeNewKey];
    
    if([[change objectForKey:NSKeyValueChangeNewKey] isEqualToString:kUserStateRideScheduled]){
        _cancelRequestButton.enabled = NO;
        _cancelRideButton.enabled = YES;
    } else if ([[change objectForKey:NSKeyValueChangeNewKey] isEqualToString:kUserStateIdle]){
        _cancelRequestButton.enabled = NO;
        _cancelRideButton.enabled = NO;
        _requestButton.enabled = YES;
    }
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[VCUserState instance].userId = [NSNumber numberWithInteger:3];
    
    NSUUID *uuidForVendor = [[UIDevice currentDevice] identifierForVendor];
    NSString *uuid = [uuidForVendor UUIDString];
    VCDevice * device = [[VCDevice alloc] init];
    //device.userId = [VCUserState instance].userId;
    // TODO once user logs in, need to update this as well
    [[RKObjectManager sharedManager] patchObject:device
                                            path: [NSString stringWithFormat:@"%@%@", API_DEVICES, uuid]
                                      parameters:nil
                                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                             NSLog(@"Push token accepted by server!");
                                             
                                         }
                                         failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                             NSLog(@"Failed send request %@", error);
                                             [WRUtilities criticalError:error];
                                             
                                             // TODO Re-transmit push token later
                                         }];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapRequestButton:(id)sender {
    VCRideRequest * request = [[VCRideRequest alloc] init];
    request.customerId = 3;
    request.type = RIDE_REQUEST_TYPE_ON_DEMAND;
    request.departureLatitude = [NSNumber numberWithDouble:((double)(-122000 + arc4random() % 1000)) / 1000];
    request.departureLongitude = [NSNumber numberWithDouble: ((double)(37000 + arc4random() % 1000)) / 1000];
    request.destinationLatitude = [NSNumber numberWithDouble:((double)(-122000 + arc4random() % 1000)) / 1000];
    request.destinationLongitude = [NSNumber numberWithDouble: ((double)(37000 + arc4random() % 1000)) / 1000];
    
    [[RKObjectManager sharedManager] postObject:request path: API_POST_RIDE_REQUEST parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NSLog(@"Request send to server!");
                                            
                                            //VCRideRequestCreated * response = mappingResult.firstObject;
                                            _stateLabel.text = @"Ride Requested";
                                            _requestButton.enabled = NO;
                                            _cancelRequestButton.enabled = YES;
                                            
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            NSLog(@"Failed send request %@", error);
                                            [WRUtilities criticalError:error];
                                        }];
    
}

- (IBAction)didTapCancelRequestButton:(id)sender {
    _requestButton.enabled = YES;
    _cancelRequestButton.enabled = NO;
    _stateLabel.text = @"Idle";
}

- (IBAction)didTapDriverModeButton:(id)sender {
    [[[UIApplication sharedApplication] delegate].window setRootViewController:[[DriverViewController alloc] init] ];
}

- (IBAction)didTapCancelRideButton:(id)sender {
    // Send cancel request to server
    VCRideIdentity * rideIdentity = [[VCRideIdentity alloc] init];
    rideIdentity.rideId = [VCUserState instance].underwayRideId;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDER_CANCELLED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            _requestButton.enabled = YES;
                                            _cancelRideButton.enabled = NO;
                                            _cancelRequestButton.enabled = NO;
                                            [VCUserState instance].rideProcessState = kUserStateIdle;
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [WRUtilities criticalError:error];
                                        }];
}
@end
