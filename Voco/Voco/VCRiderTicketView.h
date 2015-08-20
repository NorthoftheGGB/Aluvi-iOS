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

//- (void) VCRiderTicketViewDidTapLate: (VCRiderTicketView *) riderTicketView;

@end

@interface VCRiderTicketView : UIView

@property (weak, nonatomic) id<VCRiderTicketViewDelegate> delegate;

- (void) updateInterfaceWithTicket: (Ticket*) ticket;




@end
