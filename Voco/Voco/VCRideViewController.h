//
//  VCRideViewController.h
//  Voco
//
//  Created by Elliott De Aratanha on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCTransitBaseViewController.h"
#import "Ticket.h"

@interface VCRideViewController : VCTransitBaseViewController

@property (strong, nonatomic) Ticket * ticket;
@property (strong, nonatomic) MKPolyline * walkingRouteToMeetingPointOverlay;
@property (strong, nonatomic) MKPolyline * walkingRouteToDestinationOverlay;

@end
