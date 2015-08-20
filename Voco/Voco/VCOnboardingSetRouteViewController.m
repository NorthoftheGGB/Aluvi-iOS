//
//  VCOnboardingSetRouteViewController.m
//  Voco
//
//  Created by snacks on 8/16/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOnboardingSetRouteViewController.h"
#import <Masonry.h>
#import "VCTicketViewController.h"
#import "VCStyle.h"
#import "VCMapConstants.h"

@interface VCOnboardingSetRouteViewController () <VCTicketViewControllerDelegate>

@property(nonatomic) BOOL pickupPointPicked;
@property(nonatomic) BOOL dropOffPointPicked;
@property (strong, nonatomic) IBOutlet UIView *buttonsView;
@property (strong, nonatomic) VCTicketViewController * ticketViewController;
@property (nonatomic) NSInteger editLocationType;
@end

@implementation VCOnboardingSetRouteViewController

- (id)init {
    self = [super init];
    if(self != nil){
        _pickupPointPicked = NO;
        _dropOffPointPicked = NO;
    }
    return self;
}


- (void) viewDidLoad {
    
    [_buttonsView.layer insertSublayer:[self gradientLayer:self.view.frame] atIndex:0];
    _buttonsView.frame = self.view.frame;
    [self.view addSubview:_buttonsView];
    [_buttonsView setNeedsLayout];
    

}

- (CAGradientLayer *) gradientLayer: (CGRect) frame {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(-1, 0.5);
    gradient.endPoint = CGPointMake(3.0, 0.5);
    return gradient;
}


- (void) transitionToTicketViewController: (NSInteger) editLocationType {
    
    _ticketViewController = [[VCTicketViewController alloc] init];
    [self addChildViewController:_ticketViewController];
    
    [self.view insertSubview:_ticketViewController.view atIndex:0];
  
    [_ticketViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [_ticketViewController.view setNeedsLayout];

    [_ticketViewController.view setNeedsLayout];
    _ticketViewController.delegate = self;
    [_ticketViewController didMoveToParentViewController:self];
    [_ticketViewController placeInEditLocationMode:editLocationType];
   
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = _buttonsView.frame;
        frame.origin.y = -frame.size.height;
        _buttonsView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (IBAction)didTapOnboardingPickupPointButton:(id)sender {
    _editLocationType = 1;
    [self transitionToTicketViewController: kHomeType];
}

- (IBAction)didTapOnboardingWorkLocationButton:(id)sender {
    _editLocationType = 2;
    [self transitionToTicketViewController: kWorkType];
}

- (IBAction)didTapNextButtonUserPhoto:(id)sender {
    [self.delegate VCOnboardingChildViewControllerDidFinish:self];
}


#pragma delegate
- (void) overrideUpdateLocation:(CLPlacemark*) placemark type:(NSInteger) type {
    [UIView animateWithDuration:.2 animations:^{
        _buttonsView.frame = self.view.frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)overrideCancelledUpdateLocation {
    [UIView animateWithDuration:.3 animations:^{
        [_buttonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.view.mas_top);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    } completion:^(BOOL finished) {
        
    }];
}


@end
