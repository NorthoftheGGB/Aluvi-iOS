//
//  VCRiderTicket.h
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VCRiderTicketView;

@protocol VCRiderTicketViewDelegate <NSObject>


@end

@interface VCRiderTicketView : UIView

@property (weak, nonatomic) id<VCRiderTicketViewDelegate> delegate;

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
