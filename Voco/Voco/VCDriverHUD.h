//
//  VCDriverHUD.h
//  Voco
//
//  Created by Matthew Shultz on 7/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCButtonStandardStyle.h"

@protocol VCDriverHUDDelegate <NSObject>

- (void) didRequestCallForIndex: (NSInteger) index;

@end

@interface VCDriverHUD : UIView

@property (weak, nonatomic) id<VCDriverHUDDelegate> delegate;

@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *riderButton1;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *riderButton2;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *riderButton3;
@property (weak, nonatomic) IBOutlet UIButton *callButton;

- (void) setRiderNames: (NSArray *) names;

@end
