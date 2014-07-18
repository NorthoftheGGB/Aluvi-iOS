//
//  VCDriverRecieptsDetailViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverRecieptDetailViewController.h"
#import "NSDate+Pretty.h"
#import "VCUtilities.h"
#import "Fare.h"

@interface VCDriverRecieptDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *recieptDetailTextView;

@end

@implementation VCDriverRecieptDetailViewController

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
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"Fare Id: %@", _earning.fare_id]];
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"\n\nDate: %@", [_earning.createdAt formatted]]];
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"\n\nPayment: %@", [VCUtilities formatCurrencyFromCents: _earning.amountCents]]];
    receipt = [receipt stringByAppendingString:[NSString stringWithFormat:@"\n\Route: %@", [_earning.fare routeDescription]]];
    [_recieptDetailTextView setText:receipt];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
