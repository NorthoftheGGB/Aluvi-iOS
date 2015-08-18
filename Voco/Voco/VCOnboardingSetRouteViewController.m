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
    
    _ticketViewController = [[VCTicketViewController alloc] init];
    [_ticketViewController placeInEditLocationMode];
   /* [self.view addSubview:_ticketViewController.view];
    [_ticketViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [_ticketViewController.view setNeedsLayout];
    */
    /*
    [self.view addSubview:_buttonsView];
    [_buttonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [_buttonsView setNeedsLayout];
*/
}
- (IBAction)test:(id)sender {
    _editLocationType = 1;
    [UIView animateWithDuration:.3 animations:^{
        [_buttonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.view.mas_top).with.offset(-_buttonsView.frame.size.height);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_top);
        }];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)didTapOnboardingPickupPointButton:(id)sender {
    _editLocationType = 1;
    [UIView animateWithDuration:.3 animations:^{
        [_buttonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.view.mas_top).with.offset(-_buttonsView.frame.size.height);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_top);
        }];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (IBAction)didTapOnboardingWorkLocationButton:(id)sender {
    _editLocationType = 2;
    [UIView animateWithDuration:.3 animations:^{
        [_buttonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.view.mas_top).with.offset(-_buttonsView.frame.size.height);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_top);
        }];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)didTapNextButtonUserPhoto:(id)sender {
}


#pragma delegate
- (void) overrideUpdateLocation:(CLPlacemark*) placemark type:(NSInteger) type {
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
