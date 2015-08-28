//
//  VCPaymentsView.h
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCScrollableFormViewController.h"

@class VCPaymentsViewController;

@protocol VCPaymentsViewControllerDelegate <NSObject>

- (void) VCPaymentsViewControllerDidUpdatePaymentMethod: (VCPaymentsViewController *) paymentsViewController;
- (void)  VCPaymentsViewControllerDidCancel: (VCPaymentsViewController *) paymentsViewController;

@end

@interface VCPaymentsViewController : VCScrollableFormViewController
@property(nonatomic, weak) id<VCPaymentsViewControllerDelegate> delegate;
@end
