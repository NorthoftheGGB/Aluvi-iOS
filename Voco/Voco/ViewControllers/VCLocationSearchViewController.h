//
//  VCLocationSearchControllerViewController.h
//  Voco
//
//  Created by Matthew Shultz on 7/1/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VCLocationSearchViewControllerDelegate <NSObject>

//- (void) didSelectLocation

@end

@interface VCLocationSearchViewController : UIViewController

@property(nonatomic, weak) id<VCLocationSearchViewControllerDelegate> delegate;

@end
