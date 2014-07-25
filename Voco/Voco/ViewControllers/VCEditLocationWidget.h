//
//  VCEditLocationWidget.h
//  Voco
//
//  Created by Matthew Shultz on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLocationSearchViewController.h"

#define kEditLocationWidgetEditMode 2000
#define kEditLocationWidgetDisplayMode 2001

@interface VCEditLocationWidget : UIViewController

@property(nonatomic) NSInteger mode;
@property(nonatomic, weak)  id<VCLocationSearchViewControllerDelegate> locationSearchViewControllerDelegate ;

- (void) setLocationText: (NSString *) text;

@end
