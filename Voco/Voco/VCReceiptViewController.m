//
//  VCReceiptsView.m
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCReceiptViewController.h"
#import "VCStyle.h"


@interface VCReceiptViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *receiptTableView;

@end

@implementation VCReceiptViewController




- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.view.layer insertSublayer:gradient atIndex:0];
}


-(void)viewDidLoad {
    
    [self setGradient];

}


- (IBAction)didTouchPrintReceipts:(id)sender {
}
@end
