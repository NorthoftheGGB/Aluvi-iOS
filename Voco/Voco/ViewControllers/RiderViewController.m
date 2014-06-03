//
//  RiderViewController.m
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "RiderViewController.h"
#import <RestKit.h>
#import "VCApi.h"
#import "VCRideRequest.h"
#import "VCRideRequestCreated.h"
#import "WRUtilities.h"
#import "DriverViewController.h"
#import "VCDevice.h"
#import "VCUserState.h"

static void * XXContext = &XXContext;

@interface RiderViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelRequestButton;

- (IBAction)didTapRequestButton:(id)sender;
- (IBAction)didTapCancelRequestButton:(id)sender;
- (IBAction)didTapDriverModeButton:(id)sender;

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
                                            
                                            VCRideRequestCreated * response = mappingResult.firstObject;
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
@end
