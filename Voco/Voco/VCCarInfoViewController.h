//
//  VCCarInfoViewController.h
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCCenterViewBaseViewController.h"

@class VCCarInfoViewController;

@protocol VCCarInfoViewControllerDelegate <NSObject>

- (void) VCCarInfoViewControllerDidUpdateDetails: (VCCarInfoViewController *) carInfoViewController;
- (void)  VCCarInfoViewControllerDidCancel: (VCCarInfoViewController *) carInfoViewController;

@end

@interface VCCarInfoViewController : VCCenterViewBaseViewController
@property(nonatomic, weak) id<VCCarInfoViewControllerDelegate> delegate;
@end
