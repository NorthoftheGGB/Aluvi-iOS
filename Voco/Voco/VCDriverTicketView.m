//
//  VCDriverTicket.m
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCDriverTicketView.h"
#import "Rider.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "VCStyle.h"

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
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    _riders= [ticket.riders sortedArrayUsingDescriptors:@[sortDescriptor]];
    long length = [_riders count];
    _riderOneView.hidden = YES;
    _riderTwoView.hidden = YES;
    _riderThreeView.hidden = YES;
    
    _totalRidersLabel.text = [NSString stringWithFormat:@"%ld Riders", length];
    if(length > 0){
        Rider * rider = _riders[0];
        _riderOneView.hidden = NO;
        [self showButton:_riderOneButton WithRider:rider];
    }
    if(length > 1){
        Rider * rider = _riders[1];
        _riderTwoView.hidden = NO;
        [self showButton:_riderTwoButton WithRider:rider];
    }
    if(length > 2){
        Rider * rider = _riders[2];
        _riderThreeView.hidden = NO;
        [self showButton:_riderThreeButton WithRider:rider];
    }
    _totalFareLabel.text = [NSString stringWithFormat:@"%.2f", [ticket.estimatedEarnings doubleValue] / 100];
    _ridersOnboardButton.hidden = NO;
    if([ticket.state isEqualToString:kInProgressState]){
        _ridersOnboardButton.hidden = YES;
    }
    
    
}




- (void)awakeFromNib{
    _riderOneButton.layer.cornerRadius = _riderOneButton.frame.size.width / 2;
    _riderOneButton.clipsToBounds = YES;
    _riderTwoButton.layer.cornerRadius = _riderOneButton.frame.size.width / 2;
    _riderTwoButton.clipsToBounds = YES;
    _riderThreeButton.layer.cornerRadius = _riderOneButton.frame.size.width / 2;
    _riderThreeButton.clipsToBounds = YES;


}

- (void) showButton: (UIButton * ) button WithRider: (Rider *) rider {
    [button sd_setBackgroundImageWithURL:[NSURL URLWithString: rider.smallImageUrl]
                                         forState:UIControlStateNormal
                                 placeholderImage:[UIImage imageNamed:@"placeholder-profile"]
                                          options:SDWebImageRefreshCached
     
     
     ];

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
