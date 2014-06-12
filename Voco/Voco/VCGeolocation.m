//
//  VCGeolocation.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCGeolocation.h"
#import <RestKit/RestKit.h>
#import "VCApi.h"
#import "VCLocation.h"
#import "VCUserState.h"
#import "WRUtilities.h"

static VCGeolocation * sharedGeolocation;

@interface VCGeolocation() <CLLocationManagerDelegate>

@property(nonatomic,strong) CLLocationManager * locationManager;
@property(nonatomic,strong) CLLocation * currentLocation;
@property(nonatomic,strong) NSTimer * driverLocationTimer;

- (void) sendDriverLocation:(NSTimer *)timer;

@end

@implementation VCGeolocation

+ (VCGeolocation *) sharedGeolocation{
    if( sharedGeolocation == nil){
        sharedGeolocation = [[VCGeolocation alloc] init];
    }
    return sharedGeolocation;
}

+ (CLLocation *) location{
    return [sharedGeolocation location];
}


- (id) init{
    self = [super init];
    if(self){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.pausesLocationUpdatesAutomatically = TRUE;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    sharedGeolocation = self;
    return self;
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	if(status != kCLAuthorizationStatusAuthorized){
        //This block gets called both if they decline and the first time Location Services asks for access when it doesn't already have access
        //So it gets called twice, which is confusing.
        /*
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"Location Services Declined"]
                              message:
                              [NSString stringWithFormat:@"Please enable location services for this application"]
                              delegate: self
                              cancelButtonTitle:@"Please Enable Location Services"
                              otherButtonTitles:nil
                              ];
        [alert show];
        */
	}
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
	self.currentLocation = newLocation;
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    NSString *errorType = (error.code == kCLErrorDenied) ?
    @"Access Denied" : @"Unknown Error";

    /*
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error getting Location"
                          message:errorType
                          delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil];
    [alert show];
    */
    NSLog(@"Error Getting Location: %@", errorType);
}

- (CLLocation *) location {
    return _currentLocation;
}

- (void) startTrackingDriverLocation {
    [self sendDriverLocation:nil];
    _driverLocationTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sendDriverLocation:) userInfo:nil repeats:YES];
    
}

- (void) sendDriverLocation:(NSTimer *)timer {
    VCLocation * objectLocation = [[VCLocation alloc] init];
    objectLocation.latitude = [NSNumber numberWithDouble: _currentLocation.coordinate.latitude];
    objectLocation.longitude = [NSNumber numberWithDouble: _currentLocation.coordinate.longitude];
    [[RKObjectManager sharedManager] putObject:objectLocation
                                           path:[VCApi getPutGeoCarPath:[VCUserState instance].carId]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            // nothing to do!
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [WRUtilities criticalError:error];
                                        }];
}




@end
