//
//  VCRiderHomeViewController.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Request.h"
#import "VCTripBaseViewController.h"

@interface VCRiderHomeViewController : VCTripBaseViewController

@property (strong, nonatomic) Request * request;
@property (strong, nonatomic) MKPolyline * walkingRouteToMeetingPointOverlay;
@property (strong, nonatomic) MKPolyline * walkingRouteToDestinationOverlay;

@end
