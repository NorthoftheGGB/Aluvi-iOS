//
//  VCRiderHomeViewController.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ride.h"
#import "VCTransitBaseViewController.h"

@interface VCRiderHomeViewController : VCTransitBaseViewController

@property (strong, nonatomic) Ride * request;
@property (strong, nonatomic) MKPolyline * walkingRouteToMeetingPointOverlay;
@property (strong, nonatomic) MKPolyline * walkingRouteToDestinationOverlay;

@end
