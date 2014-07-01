//
//  VCDriverHomeViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverHomeViewController.h"
#import <MapKit/MapKit.h>
#import "VCDialogs.h"

@interface VCDriverHomeViewController ()

- (IBAction)didTapAccept:(id)sender;
- (IBAction)didTapDecline:(id)sender;
- (IBAction)didTapRiderPickedUp:(id)sender;
- (IBAction)didTapCancelRide:(id)sender;

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
}


- (void) showRide{
    [self showSuggestedRoute];
    [self showRideLocations];
    self.title = [self.transport routeDescription];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)didTapAccept:(id)sender {
}

- (IBAction)didTapDecline:(id)sender {
}

- (IBAction)didTapRiderPickedUp:(id)sender {
}

- (IBAction)didTapCancelRide:(id)sender {
}
@end
