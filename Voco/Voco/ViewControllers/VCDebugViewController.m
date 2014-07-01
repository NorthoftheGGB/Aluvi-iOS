//
//  VCDebugViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDebugViewController.h"
#import "VCApi.h"
#import "VCDriverApi.h"
#import "VCInterfaceModes.h"
#import "Offer.h"
#import "VCDialogs.h"

@interface VCDebugViewController ()

@end

@implementation VCDebugViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doIt:(id)sender {
    
    [VCInterfaceModes showDriverInterface];
    [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_RIDE_OFFERS
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                      NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Offer"];
                                                      NSError * error;
                                                      
                                                      NSArray * offers = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
                                                      if(offers == nil){
                                                          [WRUtilities criticalError:error];
                                                      } else if ([offers count] == 0) {
                                                          [UIAlertView showWithTitle:@"Ride not longer available" message:@"Sorry, that ride is no longer available" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                              //do nothing
                                                          }];
                                                      } else {
                                                          Offer * offer = [offers objectAtIndex:0];
                                                          [[VCDialogs instance] offerRideToDriver:offer];
                                                      }
                                                      
                                                  
                                                  
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Failed send request %@", error);
                                                  [WRUtilities criticalError:error];
                                                  
                                                  // TODO Re-transmit push token later
                                              }];

    
    /*
    [VCDriverApi loadDriveDetails:[NSNumber numberWithInt:404] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
     
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

    }];
     */
}

- (IBAction)exitDebugHelper:(id)sender {
    [VCInterfaceModes showInterface];
}

@end
