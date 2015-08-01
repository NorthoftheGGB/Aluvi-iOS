//
//  VCLocationSearchControllerViewController.h
//  Voco
//
//  Created by Matthew Shultz on 7/1/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@protocol VCLocationSearchViewControllerDelegate <NSObject>

- (void) didSelectLocation: (MKMapItem *) mapItem;

@end

@interface VCLocationSearchViewController : UITableViewController

@property(nonatomic, weak) id<VCLocationSearchViewControllerDelegate> delegate;

@end
