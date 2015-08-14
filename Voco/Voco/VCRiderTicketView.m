//
//  VCRiderTicket.m
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCRiderTicketView.h"

@interface VCRiderTicketView ()

@property (strong, nonatomic) IBOutlet UIButton *riderLateButton;
@property (strong, nonatomic) IBOutlet UILabel *totalCostLabel;
@property (strong, nonatomic) IBOutlet UILabel *driverDetails;
@property (strong, nonatomic) IBOutlet UIButton *driverImageButton;
@property (strong, nonatomic) IBOutlet UILabel *peersLabel;
@property (strong, nonatomic) IBOutlet UIButton *peerOneButton;
@property (strong, nonatomic) IBOutlet UIButton *peerTwoButton;

- (IBAction)didTapUpButton:(id)sender;

- (IBAction)didTapRiderLateButton:(id)sender;
- (IBAction)didTapDriverImageButton:(id)sender;
- (IBAction)didTapPeerOneButton:(id)sender;
- (IBAction)didTapPeerTwoButton:(id)sender;

@end

@implementation VCRiderTicketView

- (void) updateInterfaceWithTicket: (Ticket*) ticket {
    // ticket needs method for 'other riders'. not including the one using the app.
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
