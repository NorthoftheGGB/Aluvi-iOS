//
//  VCRiderHomeViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderHomeViewController.h"
#import <MapKit/MapKit.h>
#import "VCRideRequest.h"
#import "VCUserState.h"
#import <MBProgressHUD.h>

#import <RestKit.h>
#import "VCApi.h"

#define kStepSetDepartureLocation 1
#define kStepSetDestinationLocation 2

@interface VCRiderHomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *mapCenterPin;
@property (weak, nonatomic) IBOutlet UIView *departureEntryView;
@property (weak, nonatomic) IBOutlet UIView *destinationEntryView;
@property (weak, nonatomic) IBOutlet UIButton *onDemandButton;
@property (weak, nonatomic) IBOutlet UIButton *commuteButton;
@property (weak, nonatomic) IBOutlet UIView *locationConfirmationAnnotation;
@property (weak, nonatomic) IBOutlet UILabel *locationConfirmationLabel;
@property (strong, nonatomic) MKMapView * map;

@property (nonatomic) NSInteger step;
@property (strong, nonatomic) VCRideRequest * rideRequest;

- (IBAction)didTapCommute:(id)sender;
- (IBAction)didTapOnDemand:(id)sender;
- (IBAction)didTapConfirmLocation:(id)sender;

@end

@implementation VCRiderHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _step = kStepSetDepartureLocation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapCenterPin.hidden = YES;
    _locationConfirmationAnnotation.hidden = YES;
    
    _map = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _map.showsUserLocation = YES;
    _map.userTrackingMode = YES;
    [self.view insertSubview:_map atIndex:0];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapCommute:(id)sender {
}

- (IBAction)didTapOnDemand:(id)sender {
    _onDemandButton.hidden = YES;
    _commuteButton.hidden = YES;
    _mapCenterPin.hidden = NO;
    _locationConfirmationAnnotation.hidden = NO;
    
    _rideRequest = [[VCRideRequest alloc] init];
    _rideRequest.type = RIDE_REQUEST_TYPE_ON_DEMAND;
    _rideRequest.customerId = [[VCUserState instance].userId intValue];
    
    CGRect frame = _departureEntryView.frame;
    frame.origin.y = 20;
    _departureEntryView.frame = frame;
    [self.view addSubview:_departureEntryView];
}

- (IBAction)didTapConfirmLocation:(id)sender {
    if(_step == kStepSetDepartureLocation){
        CLLocationCoordinate2D departureLocation = [_map centerCoordinate];
        _rideRequest.departureLatitude = [NSNumber numberWithDouble: departureLocation.latitude];
        _rideRequest.departureLongitude = [NSNumber numberWithDouble: departureLocation.longitude];
        _step = kStepSetDestinationLocation;
        
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(departureLocation.latitude, departureLocation.longitude);
        myAnnotation.title = @"Pickup Location";
        myAnnotation.subtitle = @"Click to change";
        [_map addAnnotation:myAnnotation];
        
        _locationConfirmationLabel.text = @"Set Drop Off Location";
        
        [_departureEntryView removeFromSuperview];
        CGRect frame = _destinationEntryView.frame;
        frame.origin.y = 20;
        _destinationEntryView.frame = frame;
        [self.view addSubview:_destinationEntryView];
        
    } else if (_step == kStepSetDestinationLocation) {
        CLLocationCoordinate2D destinationLocation = [_map centerCoordinate];
        _rideRequest.destinationLatitude = [NSNumber numberWithDouble: destinationLocation.latitude];
        _rideRequest.destinationLongitude = [NSNumber numberWithDouble: destinationLocation.longitude];
        
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(destinationLocation.latitude, destinationLocation.longitude);
        myAnnotation.title = @"Drop Off Location";
        myAnnotation.subtitle = @"Click to change";
        [_map addAnnotation:myAnnotation];
        
        _mapCenterPin.hidden = YES;
        _locationConfirmationAnnotation.hidden = YES;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Requesting Ride";
        [[RKObjectManager sharedManager] postObject:_rideRequest path: API_POST_RIDE_REQUEST parameters:nil
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                NSLog(@"Ride request accepted by server!");
                                                [hud hide:YES];
                                                
                                                //VCRideRequestCreated * response = mappingResult.firstObject;
                                                //_stateLabel.text = @"Ride Requested";
                                                //_requestButton.enabled = NO;
                                                //_cancelRequestButton.enabled = YES;
                                                
                                            }
                                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                [hud hide:YES];

                                                NSLog(@"Failed send request %@", error);
                                                [WRUtilities criticalError:error];
                                            }];
    }
}
@end
