//
//  VCRiderRecieptDetailViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderRecieptDetailViewController.h"
#import "VCUtilities.h"
#import "NSDate+Pretty.h"

@interface VCRiderRecieptDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *recieptTextView;

@end

@implementation VCRiderRecieptDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString * receipt = [[NSString alloc] init];
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"Ride Id: %@", _payment.ride_id]];
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"\n\nDate: %@", [_payment.createdAt formatted]]];
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"\n\nPayment: %@", [VCUtilities formatCurrencyFromCents: _payment.amountCents]]];
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"\n\nStatus: %@", _payment.stripeChargeStatus]];
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"\n\nDate Charged: %@", [_payment.capturedAt formatted]]];
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"\n\nPayment Type: %@", _payment.motive]];
    [_recieptTextView setText:receipt];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
