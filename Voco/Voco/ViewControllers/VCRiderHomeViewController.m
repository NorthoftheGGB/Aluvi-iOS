//
//  VCRiderHomeViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderHomeViewController.h"
#import <MapKit/MapKit.h>
#import <MBProgressHUD.h>
#import "VCUserState.h"
#import "VCInterfaceModes.h"
#import "Ride.h"
#import "VCRiderApi.h"
#import "VCMapQuestRouting.h"

#define kStepSetDepartureLocation 1
#define kStepSetDestinationLocation 2

@interface VCRiderHomeViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mapCenterPin;
@property (weak, nonatomic) IBOutlet UIView *departureEntryView;
@property (weak, nonatomic) IBOutlet UIView *destinationEntryView;
@property (weak, nonatomic) IBOutlet UIButton *onDemandButton;
@property (weak, nonatomic) IBOutlet UIButton *commuteButton;
@property (weak, nonatomic) IBOutlet UIView *locationConfirmationAnnotation;
@property (weak, nonatomic) IBOutlet UILabel *locationConfirmationLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;

// Map
@property (strong, nonatomic) MKMapView * map;
@property (strong, nonatomic) MKPolyline * routeOverlay;

@property (nonatomic) NSInteger step;
@property (strong, nonatomic) Ride * ride;

- (IBAction)didTapCommute:(id)sender;
- (IBAction)didTapOnDemand:(id)sender;
- (IBAction)didTapConfirmLocation:(id)sender;
- (IBAction)didTapLogout:(id)sender;
- (IBAction)didTapCancel:(id)sender;

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
    _cancelRideButton.hidden = YES;
    
    _map = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _map.delegate = self;
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
    _cancelRideButton.hidden = NO;

    
    _ride = (Ride *) [NSEntityDescription insertNewObjectForEntityForName:@"Ride" inManagedObjectContext:[VCCoreData managedObjectContext]];
    _ride.requestType = RIDE_REQUEST_TYPE_ON_DEMAND;
    
    CGRect frame = _departureEntryView.frame;
    frame.origin.y = 20;
    _departureEntryView.frame = frame;
    [self.view addSubview:_departureEntryView];
}

- (IBAction)didTapConfirmLocation:(id)sender {
    if(_step == kStepSetDepartureLocation){
        CLLocationCoordinate2D departureLocation = [_map centerCoordinate];
        _ride.originLatitude = [NSNumber numberWithDouble: departureLocation.latitude];
        _ride.originLongitude= [NSNumber numberWithDouble: departureLocation.longitude];
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
        _ride.destinationLatitude = [NSNumber numberWithDouble: destinationLocation.latitude];
        _ride.destinationLongitude = [NSNumber numberWithDouble: destinationLocation.longitude];
        
        //TODO: create confirmation step and UI
        CLLocationCoordinate2D destinationCoordinate;
        CLLocationCoordinate2D departureCoordinate;
        destinationCoordinate.latitude = [_ride.destinationLatitude doubleValue];
        destinationCoordinate.longitude = [_ride.destinationLongitude doubleValue];
        departureCoordinate.latitude = [_ride.originLatitude doubleValue];
        departureCoordinate.longitude = [_ride.originLongitude doubleValue];

        [VCMapQuestRouting route:destinationCoordinate to:departureCoordinate region:_map.region success:^(MKPolyline *polyline) {
            _routeOverlay = polyline;
            [_map addOverlay:_routeOverlay];
        } failure:^{
            NSLog(@"%@", @"Error talking with MapQuest routing API");
        }];
        
        
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
        
        // VC RidesAPI
        [VCRiderApi requestRide:_ride success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [hud hide:YES];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [hud hide:YES];
        }];
        
    }
}

- (IBAction)didTapLogout:(id)sender {
    [[VCUserState instance] logout];
    [VCInterfaceModes showRiderSigninInterface];
}

- (IBAction)didTapCancel:(id)sender {
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Canceling Ride";
    

    // VC RidesAPI
    [VCRiderApi cancelRide:_ride success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [_map removeAnnotations:_map.annotations];
        _locationConfirmationLabel.text = @"Set Pick Up Location";
        _mapCenterPin.hidden = YES;
        _locationConfirmationAnnotation.hidden = YES;
        _destinationEntryView.hidden = YES;
        _departureEntryView.hidden = YES;
        _onDemandButton.hidden = NO;
        _commuteButton.hidden = NO;
        _cancelRideButton.hidden = YES;
        _step = kStepSetDepartureLocation;
        [_map removeOverlay:_routeOverlay];
        [hud hide:YES];
        
        [UIAlertView showWithTitle:@"Ride Cancelled" message:@"Your ride has been cancelled" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [WRUtilities criticalError:error];
    }];
    
}

#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer*    aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
        
        aRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aRenderer.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        aRenderer.lineWidth = 3;
        
        return aRenderer;
    }
    
    return nil;
}

@end
