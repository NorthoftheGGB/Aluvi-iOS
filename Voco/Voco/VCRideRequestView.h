//
//  VCRideRequest.h
//  Voco
//
//  Created by snacks on 7/30/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
#import "Route.h"

#define kHomeType 3000
#define kWorkType 3001

@class VCRideRequestView;

@protocol VCRideRequestViewDelegate <NSObject>

- (void) rideRequestView: (VCRideRequestView *) rideRequestView didTapEditLocation:  (CLLocationCoordinate2D) location locationName:(NSString *) locationName type:(NSInteger) type;
- (void) rideRequestView: (VCRideRequestView *) rideRequestView didTapScheduleCommute:(Route *) route;

- (void) rideRequestViewDidCancel: (VCRideRequestView *) rideRequestView;
- (void) rideRequestViewDidTapClose: (VCRideRequestView *) rideRequestView withChanges: (Route *) route;

@end

@interface VCRideRequestView : UIView

@property (weak, nonatomic) id<VCRideRequestViewDelegate> delegate;

- (void) updateLocation:(MKPlacemark*) placemark type:(NSInteger) type;
- (void) updateWithRoute:(Route *) route;


@end

//TODO it would be useful for fromButton to retain the 'from'
