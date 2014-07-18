//
//  VCDriverHUD.h
//  Voco
//
//  Created by Matthew Shultz on 7/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCButtonFontBold.h"

@protocol VCDriverHUDDelegate <NSObject>

- (void) didRequestCallForIndex: (NSInteger) index;

@end

@interface VCDriverHUD : UIView

@property (weak, nonatomic) id<VCDriverHUDDelegate> delegate;

@property (weak, nonatomic) IBOutlet VCButtonFontBold *riderButton1;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *riderButton2;
@property (weak, nonatomic) IBOutlet VCButtonFontBold *riderButton3;
@property (weak, nonatomic) IBOutlet UIButton *callButton;

- (void) setRiderNames: (NSArray *) names;

@end
