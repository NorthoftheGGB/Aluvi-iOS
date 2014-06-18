//
//  DriverViewController.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "DriverViewController.h"
#import "VCDevice.h"
#import "WRUtilities.h"
#import "RiderViewController.h"
#import "VCUserState.h"
#import "VCRideDriverAssignment.h"
#import "VCRideIdentity.h"
#import "VCGeolocation.h"

static void * XXContext = &XXContext;

@interface DriverViewController ()


@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;
@property (weak, nonatomic) IBOutlet UIButton *rideCompletedButton;
@property (weak, nonatomic) IBOutlet UIButton *pickedUpRiderButton;
- (IBAction)didTapRiderModeButton:(id)sender;
- (IBAction)didTapCancelRide:(id)sender;
- (IBAction)didTapPickedUpRider:(id)sender;
- (IBAction)didTapRideCompleted:(id)sender;

@end

@implementation DriverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[VCUserState instance] addObserver:self forKeyPath:@"driverState" options:NSKeyValueObservingOptionNew context:XXContext];
    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    [[VCUserState instance] removeObserver:self forKeyPath:@"driverState"];
}

- (void)dealloc {
    [[VCUserState instance] removeObserver:self forKeyPath:@"driverState"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    _stateLabel.text = [change objectForKey:NSKeyValueChangeNewKey];
    
    // Map overlay controls should be handled by KVO
    if([[change objectForKey:NSKeyValueChangeNewKey] isEqualToString:kUserStateRideAccepted]){
        _cancelRideButton.enabled = YES;
        _pickedUpRiderButton.enabled = YES;
        _rideCompletedButton.enabled = YES;
    } else if([[change objectForKey:NSKeyValueChangeNewKey] isEqualToString:kUserStateRideCompleted]){
        _cancelRideButton.enabled = NO;
        _pickedUpRiderButton.enabled = NO;
        _rideCompletedButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapRiderModeButton:(id)sender {
    [[[UIApplication sharedApplication] delegate].window setRootViewController:[[RiderViewController alloc] init] ];

}

- (IBAction)didTapCancelRide:(id)sender {
    // Send cancel request to server
    VCRideDriverAssignment * rideIdentity = [[VCRideDriverAssignment alloc] init];
    rideIdentity.rideId = [VCUserState instance].rideId;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_DRIVER_CANCELLED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            _cancelRideButton.enabled = NO;
                                            _pickedUpRiderButton.enabled = NO;
                                            _rideCompletedButton.enabled = NO;
                                            [VCUserState instance].driverState = kUserStateIdle;
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [WRUtilities criticalError:error];
                                        }];

}

- (IBAction)didTapPickedUpRider:(id)sender {
    VCRideDriverAssignment * rideIdentity = [[VCRideDriverAssignment alloc] init];
    rideIdentity.rideId = [VCUserState instance].rideId;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDE_PICKUP parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [VCUserState instance].driverState = kUserStateRideStarted;
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [WRUtilities criticalError:error];
                                        }];
}

- (IBAction)didTapRideCompleted:(id)sender {
    VCRideDriverAssignment * rideIdentity = [[VCRideDriverAssignment alloc] init];  // TODO objects like this can be generated from
                                                                    // global state of the app, i.e. in another method
    rideIdentity.rideId = [VCUserState instance].rideId;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDE_ARRIVED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [VCUserState instance].driverState = kUserStateRideCompleted;
                                            [self showReceipt];
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [WRUtilities criticalError:error];
                                        }];
}

- (void) showReceipt {
    [UIAlertView showWithTitle:@"Receipt"
                       message:@"This is a placeholder for the receipt view.  Thanks for driving!"
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [VCUserState instance].driverState = kUserStateIdle;

    }];
}
@end
