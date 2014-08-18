//
//  VCDriveViewController.h
//  Voco
//
//  Created by Elliott De Aratanha on 7/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCTransitBaseViewController.h"
#import "Ride.h"

@interface VCDriveViewController : VCTransitBaseViewController

@property (nonatomic, strong) Ride * ride; // should be FARE not RIDE

@end
