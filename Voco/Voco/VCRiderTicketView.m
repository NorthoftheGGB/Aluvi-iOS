//
//  VCRiderTicket.m
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCRiderTicketView.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "Rider.h"
#import "Driver.h"
#import "Car.h"
#import "VCLabelSmall.h"
#import "VCLabel.h"
#import "VCRiderView.h"

@interface VCRiderTicketView ()

@property (strong, nonatomic) IBOutlet UIButton *riderLateButton;
@property (strong, nonatomic) IBOutlet UILabel *totalCostLabel;
@property (strong, nonatomic) IBOutlet UILabel *driverDetails;
@property (strong, nonatomic) IBOutlet UIButton *driverImageButton;
@property (strong, nonatomic) IBOutlet UILabel *peersLabel;
@property (strong, nonatomic) IBOutlet UIButton *peerOneButton;
@property (strong, nonatomic) IBOutlet UIButton *peerTwoButton;
@property (strong, nonatomic) IBOutlet VCLabelSmall *carLabel;
@property (strong, nonatomic) IBOutlet VCLabelSmall *licensePlateLabel;
@property (strong, nonatomic) IBOutlet VCLabel *driverNameLabel;
@property (strong, nonatomic) IBOutlet VCRiderView *riderOneView;
@property (strong, nonatomic) IBOutlet VCRiderView *riderTwoView;
@property (strong, nonatomic) IBOutlet VCLabelSmall *riderOneLabel;
@property (strong, nonatomic) IBOutlet VCLabelSmall *riderTwoLabel;


@property (nonatomic, strong) NSArray * riders;


- (IBAction)didTapUpButton:(id)sender;

- (IBAction)didTapRiderLateButton:(id)sender;
- (IBAction)didTapDriverImageButton:(id)sender;
- (IBAction)didTapPeerOneButton:(id)sender;
- (IBAction)didTapPeerTwoButton:(id)sender;

@end

@implementation VCRiderTicketView

-(void)awakeFromNib {
    _peerOneButton.layer.cornerRadius = _peerOneButton.frame.size.width / 2;
    _peerOneButton.clipsToBounds = YES;
    _peerTwoButton.layer.cornerRadius = _peerTwoButton.frame.size.width / 2;
    _peerTwoButton.clipsToBounds = YES;
    _driverImageButton.layer.cornerRadius = _driverImageButton.frame.size.width / 2;
    _driverImageButton.clipsToBounds = YES;
    

}

- (void) updateInterfaceWithTicket: (Ticket *) ticket {
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    [self showButton:_driverImageButton WithURLString:ticket.driver.smallImageUrl];
     _totalCostLabel.text = [NSString stringWithFormat:@"%.2f", [ticket.fixedPrice doubleValue] / 100];
    
    _riders= [ticket.riders sortedArrayUsingDescriptors:@[sortDescriptor]];

    long length = [_riders count];
    _riderOneView.hidden = YES;
    _riderTwoView.hidden = YES;
    
    if(length > 0){
        [self showRiderView:_riderOneView withRider:_riders[0]];
    }
    if(length > 1){
        _riderTwoView.hidden = NO;
        [self showRiderView:_riderOneView withRider:_riders[1]];
    }
    
    _carLabel.text = [ticket.car summary];
    _licensePlateLabel.text = ticket.car.licensePlate;
    _driverNameLabel.text = ticket.driver.firstName;
    
    _peersLabel.text = [NSString stringWithFormat:@"%lu Other Riders", (unsigned long)[_riders count]];
    
}

- (void) showRiderView: (VCRiderView *) riderView withRider: (Rider *) rider {
    
    [self showButton:riderView.button WithURLString:rider.smallImageUrl];
    riderView.label.text = [rider firstName];
    riderView.hidden = NO;
    
}
     
- (void) showButton: (UIButton * ) button WithURLString: (NSString *) url {
         
         [button sd_setBackgroundImageWithURL:[NSURL URLWithString: url]
                                     forState:UIControlStateNormal
                             placeholderImage:[UIImage imageNamed:@"placeholder-profile"]
                                      options:SDWebImageRefreshCached
          ];
         
     }


- (IBAction)didTapLate:(id)sender {
}


- (IBAction)didTapUpButton:(id)sender {
    
}

- (IBAction)didTapRiderLateButton:(id)sender {
}

- (IBAction)didTapDriverImageButton:(id)sender {
}

- (IBAction)didTapPeerOneButton:(id)sender {
}

- (IBAction)didTapPeerTwoButton:(id)sender {
}
@end
