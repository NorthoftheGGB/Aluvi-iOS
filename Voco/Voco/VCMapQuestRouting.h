//
//  VCMapQuestRouting.h
//  Voco
//
//  Created by Matthew Shultz on 6/12/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface VCMapQuestRouting : NSObject

+ (void) setup;


+ (void) route: (CLLocationCoordinate2D) start
            to: (CLLocationCoordinate2D) end
       success: ( void ( ^ ) ( MKPolyline * polyline, MKCoordinateRegion region )) success
       failure: ( void ( ^ ) ( )) failure;

+ (void) pedestrianRoute: (CLLocationCoordinate2D) start
                      to: (CLLocationCoordinate2D) end
                 success: ( void ( ^ ) ( MKPolyline * polyline, MKCoordinateRegion region )) success
                 failure: ( void ( ^ ) ( )) failure;

+ (void) route: (CLLocationCoordinate2D) start
            to: (CLLocationCoordinate2D) end
        options: (NSDictionary *) options
       success: ( void ( ^ ) ( MKPolyline * polyline, MKCoordinateRegion region )) success
       failure: ( void ( ^ ) ( )) failure;
@end
