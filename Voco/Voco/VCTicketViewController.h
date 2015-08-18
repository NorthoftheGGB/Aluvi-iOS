//
//  VCRideViewController.h
//  Voco
//
//  Created by Elliott De Aratanha on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCCenterViewBaseViewController.h"
#import "Ticket.h"

@protocol VCTicketViewControllerDelegate <NSObject>

- (void) overrideUpdateLocation:(CLPlacemark*) placemark type:(NSInteger) type;
- (void) overrideCancelledUpdateLocation;

@end

@interface VCTicketViewController : VCCenterViewBaseViewController

@property (weak, nonatomic) id<VCTicketViewControllerDelegate> delegate;
@property (strong, nonatomic) Ticket * ticket;
@property (nonatomic) BOOL isFinished;  // for KVO


- (void) placeInEditLocationMode;
- (void) placeInRouteMode;

@end
