//
//  VCLocationSearchControllerViewController.h
//  Voco
//
//  Created by Matthew Shultz on 7/1/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
@import MapKit.MKLocalSearch;
@import MapKit.MKLocalSearchRequest;
@import MapKit.MKLocalSearchResponse;

@class VCLocationSearchViewController;

@protocol VCLocationSearchViewControllerDelegate <NSObject>

- (void) locationSearchViewController: (VCLocationSearchViewController *) locationSearchViewController didSelectLocation: (MKMapItem *) mapItem;

@end

@interface VCLocationSearchViewController : UITableViewController

@property(nonatomic, weak) id<VCLocationSearchViewControllerDelegate> delegate;


- (void)didEditSearchText:(NSString*) text;

@end
