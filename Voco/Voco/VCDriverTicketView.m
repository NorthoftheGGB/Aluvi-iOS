//
//  VCDriverTicket.m
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCDriverTicketView.h"
#import "Fare.h"
#import "Rider.h"

@interface VCDriverTicketView ()

@property (strong, nonatomic) IBOutlet UIButton *ridersOnboardButton;
@property (strong, nonatomic) IBOutlet UILabel *totalFareLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalRidersLabel;
@property (strong, nonatomic) IBOutlet UIView *riderOneView;
@property (strong, nonatomic) IBOutlet UIView *riderTwoView;
@property (strong, nonatomic) IBOutlet UIView *riderThreeView;
@property (strong, nonatomic) IBOutlet UIButton *riderOneButton;
@property (strong, nonatomic) IBOutlet UIButton *riderTwoButton;
@property (strong, nonatomic) IBOutlet UIButton *riderThreeButton;

- (IBAction)didTapRidersOnboardButton:(id)sender;
- (IBAction)didTapRiderOneButton:(id)sender;
- (IBAction)didTapRiderTwoButton:(id)sender;
- (IBAction)didTapRiderThreeButton:(id)sender;

@property (nonatomic, strong) NSArray * riders;


@end

@implementation VCDriverTicketView

- (void) updateInterfaceWithTicket: (Ticket *) ticket {
    Fare * fare = ticket.hovFare;
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    _riders= [fare.riders sortedArrayUsingDescriptors:@[sortDescriptor]];
    long length = [_riders count];
    _riderOneView.hidden = YES;
    _riderTwoView.hidden = YES;
    _riderThreeView.hidden = YES;
    if(length > 0){
        Rider * rider = _riders[0];
        _riderOneView.hidden = NO;
        // Use SDWebImage, APSmartStore, DLImageLoader or something simlar to load these images
        //[_riderOneButton setBackgroundImage:rider.smallImageUrl forState:UIControlStateNormal];
    }
    if(length > 1){
        Rider * rider = _riders[1];
        _riderTwoView.hidden = NO;
    }
    if(length > 2){
        Rider * rider = _riders[2];
        _riderThreeView.hidden = NO;
    }
}


- (IBAction)didTapRidersOnboardButton:(id)sender {
    [_delegate VCDriverTicketViewDidTapRidersOnBoard:self success:^{
        _ridersOnboardButton.hidden = YES;
    }];
}


- (void) callRider: (Rider *) rider {
    if(rider.phone != nil){
        [_delegate  VCDriverTicketView:self didTapCallRider:rider.phone];
    }

}

- (IBAction)didTapRiderOneButton:(id)sender {
    [self callRider: _riders[0]];
}

- (IBAction)didTapRiderTwoButton:(id)sender {
    [self callRider: _riders[1]];
}

- (IBAction)didTapRiderThreeButton:(id)sender {
    [self callRider: _riders[2]];
}

@end
