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
#define kHomeType 3000
#define kWorkType 3001

@class VCEditLocationWidget;

@protocol VCEditLocationWidgetDelegate <NSObject>

- (void) editLocationWidget: (VCEditLocationWidget *) widget didSelectMapItem: (MKMapItem *) mapItem;

@end

@interface VCEditLocationWidget : UIViewController

@property(nonatomic) NSInteger mode;
@property(nonatomic, weak)  id<VCEditLocationWidgetDelegate> delegate ;
@property (nonatomic) NSInteger type;
@property (nonatomic) BOOL waiting;

- (void) setLocationText: (NSString *) text;
- (NSString *) locationText;

@end
