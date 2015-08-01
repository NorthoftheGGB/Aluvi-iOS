//
//  VCDriverTicket.h
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VCDriverTicketView;

@protocol VCDriverTicketViewDelegate <NSObject>

- (VCDriverTicketView *) didTapCallRider: (NSInteger) riderId;

@end

@interface VCDriverTicketView : UIView

@property (weak, nonatomic) id<VCDriverTicketViewDelegate> delegate;

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

@end
