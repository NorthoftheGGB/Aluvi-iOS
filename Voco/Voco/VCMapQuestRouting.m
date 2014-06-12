//
//  VCMapQuestRouting.m
//  Voco
//
//  Created by Matthew Shultz on 6/12/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCMapQuestRouting.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MQRouteResponse.h"

@implementation VCMapQuestRouting

- (void) route: (CLLocationCoordinate2D) start
            to: (CLLocationCoordinate2D) end
        region: (MKCoordinateRegion) region
       success: ( void ( ^ ) ( MKPolyline * polyline )) success
       failure: ( void ( ^ ) ( )) failure {
    
    double height = region.span.latitudeDelta;
    double width = region.span.longitudeDelta;
    NSString * url = [NSString stringWithFormat:@"http://www.mapquestapi.com/directions/v2/route?key=%@&from=%f,%f&to=%f,%f&shapeFormat=raw&mapWidth=%f&mapHeight=%f",
                      MAPQUEST_API_KEY, start.latitude, start.longitude, end.latitude, end.longitude, width, height ];
    [[RKObjectManager sharedManager] getObject:nil path:url parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        MQRouteResponse * route = mappingResult.firstObject;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];
}

@end
