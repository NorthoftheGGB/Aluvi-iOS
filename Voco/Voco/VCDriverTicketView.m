//
//  VCDriverTicket.m
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCDriverTicketView.h"
#import <SDWebImage/UIButton+WebCache.h>
#import <Masonry.h>
#import "VCRiderView.h"
#import "Rider.h"
#import "VCStyle.h"

@interface VCDriverTicketView ()

@property (strong, nonatomic) IBOutlet UILabel *totalFareLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalRidersLabel;
@property (strong, nonatomic) IBOutlet VCRiderView *riderOneView;
@property (strong, nonatomic) IBOutlet VCRiderView *riderTwoView;
@property (strong, nonatomic) IBOutlet VCRiderView *riderThreeView;
@property (strong, nonatomic) IBOutlet UIButton *riderOneButton;
@property (strong, nonatomic) IBOutlet UIButton *riderTwoButton;
@property (strong, nonatomic) IBOutlet UIButton *riderThreeButton;

- (IBAction)didTapRiderOneButton:(id)sender;
- (IBAction)didTapRiderTwoButton:(id)sender;
- (IBAction)didTapRiderThreeButton:(id)sender;

@property (nonatomic, strong) NSArray * riders;


@end

@implementation VCDriverTicketView


- (void)awakeFromNib{
    _riderOneButton.layer.cornerRadius = _riderOneButton.frame.size.width / 2;
    _riderOneButton.clipsToBounds = YES;
    _riderTwoButton.layer.cornerRadius = _riderTwoButton.frame.size.width / 2;
    _riderTwoButton.clipsToBounds = YES;
    _riderThreeButton.layer.cornerRadius = _riderThreeButton.frame.size.width / 2;
    _riderThreeButton.clipsToBounds = YES;
}

- (void) updateInterfaceWithTicket: (Ticket *) ticket {
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    _riders= [ticket.riders sortedArrayUsingDescriptors:@[sortDescriptor]];
    long length = [_riders count];
    _riderOneView.hidden = YES;
    _riderTwoView.hidden = YES;
    _riderThreeView.hidden = YES;
    
    _totalRidersLabel.text = [NSString stringWithFormat:@"%ld Riders", length];
    if(length > 0){
        [self showRiderView:_riderOneView withRider:_riders[0]];
    }
    if(length > 1){
        [self showRiderView:_riderTwoView withRider:_riders[1]];

    }
    if(length > 2){
        [self showRiderView:_riderThreeView withRider:_riders[2]];
    }
    _totalFareLabel.text = [NSString stringWithFormat:@"%.2f", [ticket.estimatedEarnings doubleValue] / 100];
    
    
    
}



- (void) showRiderView: (VCRiderView *) riderView withRider: (Rider *) rider {
    
    [self showButton:riderView.button WithRider:rider];
    riderView.label.text = [rider fullName];
    riderView.hidden = NO;
    
}


- (void) showButton: (UIButton * ) button WithRider: (Rider *) rider {
    [button sd_setBackgroundImageWithURL:[NSURL URLWithString: rider.smallImageUrl]
                                         forState:UIControlStateNormal
                                 placeholderImage:[UIImage imageNamed:@"placeholder-profile"]
                                          options:SDWebImageRefreshCached
     
     
     ];

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
