//
//  VCRiderTicket.h
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ticket.h"

@class VCRiderTicketView;

@protocol VCRiderTicketViewDelegate <NSObject>

- (void) VCRiderTicketView: (VCRiderTicketView *) riderTicketView didTapCallRider:(NSString *)phoneNumber;
- (void) VCRiderTicketView: (VCRiderTicketView *) riderTicketView didTapCallDrive:(NSString *)phoneNumber;

@end

@interface VCRiderTicketView : UIView

@property (strong, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) id<VCRiderTicketViewDelegate> delegate;

- (void) updateInterfaceWithTicket: (Ticket*) ticket;




@end
