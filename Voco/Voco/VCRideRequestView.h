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



@class VCRideRequestView;

@protocol VCRideRequestViewDelegate <NSObject>

- (void) rideRequestView: (VCRideRequestView *) rideRequestView didTapEditLocation:  (CLLocationCoordinate2D) location locationName:(NSString *) locationName type:(NSInteger) type;
- (void) rideRequestView: (VCRideRequestView *) rideRequestView didTapScheduleCommute:(Route *) route;
- (void) rideRequestViewDidCancelCommute: (VCRideRequestView *) rideRequestView;

- (void) rideRequestViewDidCancel: (VCRideRequestView *) rideRequestView;
- (void) rideRequestViewDidTapClose: (VCRideRequestView *) rideRequestView withChanges: (Route *) route;

@end

@interface VCRideRequestView : UIView

@property (weak, nonatomic) id<VCRideRequestViewDelegate> delegate;

- (void) updateLocation:(MKPlacemark*) placemark type:(NSInteger) type;
- (void) updateWithRoute:(Route *) route;
- (void) setEditable:(BOOL) editable;


@end

//TODO it would be useful for fromButton to retain the 'from'
