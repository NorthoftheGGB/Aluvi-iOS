//
//  VCRiderHomeViewController.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Request.h"
#import "VCRideViewController.h"

@interface VCRiderHomeViewController : VCRideViewController

@property (strong, nonatomic) Request * ride;

@end
