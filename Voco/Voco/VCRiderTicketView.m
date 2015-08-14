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

@property (nonatomic, strong) NSArray * riders;


- (IBAction)didTapUpButton:(id)sender;

- (IBAction)didTapRiderLateButton:(id)sender;
- (IBAction)didTapDriverImageButton:(id)sender;
- (IBAction)didTapPeerOneButton:(id)sender;
- (IBAction)didTapPeerTwoButton:(id)sender;

@end

@implementation VCRiderTicketView

- (void) updateInterfaceWithTicket: (Ticket *) ticket {
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    [self showButton:_driverImageButton WithURLString:ticket.driver.smallImageUrl];
    _totalCostLabel.text = [NSString stringWithFormat:@"%.2f", [ticket.fixedPrice doubleValue] / 100];
    
    _riders= [ticket.riders sortedArrayUsingDescriptors:@[sortDescriptor]];

    long length = [_riders count];
    /*
    _riderOneView.hidden = YES;
    _riderTwoView.hidden = YES;
    _riderThreeView.hidden = YES;
    */
     
    if(length > 0){
        [self showButton:_peerOneButton WithURLString:((Rider *) _riders[0]).smallImageUrl];
    }
    if(length > 1){
        [self showButton:_peerTwoButton WithURLString:((Rider *) _riders[1]).smallImageUrl];
    }
    
    _carLabel.text = [ticket.car summary];
    _licensePlateLabel.text = ticket.car.licensePlate;
    _driverNameLabel.text = ticket.driver.fullName;
    
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
