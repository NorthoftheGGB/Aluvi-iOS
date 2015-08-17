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


@interface VCTicketViewController : VCCenterViewBaseViewController

@property (strong, nonatomic) Ticket * ticket;
@property (nonatomic) BOOL isFinished;  // for KVO

@end
