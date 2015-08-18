//
//  VCOnboardingSetRouteViewController.h
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCOnboardingChildViewController.h"
#import "Route.h"

@class VCOnboardingSetRouteViewController;

@protocol VCOnboardingSetRouteViewControllerDelegate <NSObject>

- (void) VCOnboardingSetRouteViewController: (VCOnboardingSetRouteViewController *) onboardingSetRouteViewController doneCreatingRoute: (Route*) route;

@end

@interface VCOnboardingSetRouteViewController : VCOnboardingChildViewController


- (IBAction)didTapOnboardingPickupPointButton:(id)sender;

- (IBAction)didTapOnboardingWorkLocationButton:(id)sender;

- (IBAction)didTapNextButtonUserPhoto:(id)sender;

@end
