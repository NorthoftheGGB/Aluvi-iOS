//
//  VCDriverTicket.h
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ticket.h"

@class VCDriverTicketView;

@protocol VCDriverTicketViewDelegate <NSObject>

- (void) VCDriverTicketView: (VCDriverTicketView *) driverTicketView didTapCallRider:(NSString *)phoneNumber;

@end

@interface VCDriverTicketView : UIView

@property (weak, nonatomic) id<VCDriverTicketViewDelegate> delegate;

- (void) updateInterfaceWithTicket: (Ticket *) ticket;

@end
