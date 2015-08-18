//
//  VCOnboardingSetRouteViewController.m
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingSetRouteViewController.h"
#import "VCTicketViewController.h"

@interface VCOnboardingSetRouteViewController () <VCTicketViewControllerDelegate>

@property(nonatomic) BOOL finished;

@end

@implementation VCOnboardingSetRouteViewController

- (id)init {
    self = [super init];
    if(self != nil){
        _finished = NO;
    }
    return self;
}


- (IBAction)didTapOnboardingPickupPointButton:(id)sender {
}

- (IBAction)didTapOnboardingWorkLocationButton:(id)sender {
}

- (IBAction)didTapNextButtonUserPhoto:(id)sender {
}
@end
