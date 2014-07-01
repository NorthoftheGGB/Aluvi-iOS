//
//  VCRideViewController.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ride.h"

@interface VCRideViewController : UIViewController

@property (strong, nonatomic) Ride * ride;

- (void) showSuggestedRoute;
- (void) showRideLocations;

@end
