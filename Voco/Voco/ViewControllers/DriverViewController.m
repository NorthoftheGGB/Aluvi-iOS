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

static void * XXContext = &XXContext;

@interface DriverViewController ()


@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;
- (IBAction)didTapRiderModeButton:(id)sender;
- (IBAction)didTapCancelRide:(id)sender;

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
    
    [VCUserState instance].userId = [NSNumber numberWithInteger:1];
    
    NSUUID *uuidForVendor = [[UIDevice currentDevice] identifierForVendor];
    NSString *uuid = [uuidForVendor UUIDString];
    VCDevice * device = [[VCDevice alloc] init];
    device.userId = [VCUserState instance].userId;
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
    
    if([[change objectForKey:NSKeyValueChangeNewKey] isEqualToString:kUserStateRideAccepted]){
        _cancelRideButton.enabled = YES;
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
    rideIdentity.driverId = [VCUserState instance].userId;
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_DRIVER_CANCELLED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            _cancelRideButton.enabled = NO;
                                            [VCUserState instance].riderState = kUserStateIdle;
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [WRUtilities criticalError:error];
                                        }];

}
@end
