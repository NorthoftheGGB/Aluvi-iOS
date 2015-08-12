//
//  VCPaymentsView.m
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCPaymentsViewController.h"
#import <Stripe.h>
#import <PTKView.h>
#import <PTKTextField.h>

@interface VCPaymentsViewController () <PTKViewDelegate>

@property (strong, nonatomic) PTKView * cardView;
@property (weak, nonatomic) IBOutlet UIView *PTKViewContainer;

@end

@implementation VCPaymentsViewController

- (void) viewDidLoad {
    _cardView = [[PTKView alloc] initWithFrame:CGRectMake(15,20,290,55)];
    _cardView.delegate = self;
    
    [_PTKViewContainer addSubview:_cardView];
}


- (IBAction)didTapSave:(id)sender {
}

@end
