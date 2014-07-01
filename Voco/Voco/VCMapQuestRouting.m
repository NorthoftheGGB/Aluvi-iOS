//
//  VCMapQuestRouting.m
//  Voco
//
//  Created by Matthew Shultz on 6/12/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCMapQuestRouting.h"
#import <RestKit.h>
#import "MQRouteResponse.h"

#define MAPQUEST_API_KEY @"Fmjtd|luur2guan0,b5=o5-9azxgz"

static RKObjectManager * objectManager;

@implementation VCMapQuestRouting

+ (void) setup {
    objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: @"http://www.mapquestapi.com/"]];
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MQRouteResponse getMapping] method:RKRequestMethodGET pathPattern:@"directions/v2/route" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
}

+ (void) route: (CLLocationCoordinate2D) start
            to: (CLLocationCoordinate2D) end
        region: (MKCoordinateRegion) region
       success: ( void ( ^ ) ( MKPolyline * polyline, MKCoordinateRegion region )) success
       failure: ( void ( ^ ) ( )) failure {
    
    //int height = region.span.latitudeDelta;
    //int width = region.span.longitudeDelta;
   // NSString * url = [NSString stringWithFormat:@?key=%@&from=%f,%f&to=%f,%f&shapeFormat=raw&mapWidth=%d&mapHeight=%d",
   //                   MAPQUEST_API_KEY, start.latitude, start.longitude, end.latitude, end.longitude, width, height ];
    
    /* Using fullShape for no simplication of the shape.
    * generalize parameter can be used to do some simplication for different zoom levels
     * or sending mapHeight and mapWidth for specific generalization (plus center for clipping).
     */
    NSDictionary * params = @{@"key": MAPQUEST_API_KEY,
                              @"from": [NSString stringWithFormat:@"%f,%f", start.latitude, start.longitude ],
                              @"to": [NSString stringWithFormat:@"%f,%f", end.latitude, end.longitude],
                              @"fullShape" : @"true"
                              // @"mapWidth": [NSNumber numberWithInt:width],
                             // @"mapHeight": [NSNumber numberWithInt:height]
                              };
    [objectManager cancelAllObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"directions/v2/route"];
    [objectManager getObject:nil path:@"directions/v2/route" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        MQRouteResponse * response = mappingResult.firstObject;
        if(response.route.shape == nil){
            failure();
        }
        int polylinePointCount = [response.route.shape.shapePoints count] / 2;
        CLLocationCoordinate2D *polylinePoints = (CLLocationCoordinate2D*)malloc(polylinePointCount * sizeof(CLLocationCoordinate2D) );

        for(int i=0; i < polylinePointCount; i++){
            NSNumber * latitude =  [response.route.shape.shapePoints objectAtIndex:i*2];
            NSNumber * longitude = [response.route.shape.shapePoints objectAtIndex:i*2+1];
            polylinePoints[i].latitude = [latitude doubleValue];
            polylinePoints[i].longitude = [longitude doubleValue];
        }
        MKPolyline * polyline = [MKPolyline polylineWithCoordinates:polylinePoints count:polylinePointCount];
        free(polylinePoints);
        
        MKCoordinateRegion region;
        double maxLatitude = [response.route.boundingBox.ul.lat doubleValue];
        double maxLongitude = [response.route.boundingBox.lr.lng doubleValue];
        double minLatitude = [response.route.boundingBox.lr.lat doubleValue];
        double minLongitude = [response.route.boundingBox.ul.lng doubleValue];
        region.center.latitude = (minLatitude + maxLatitude) / 2;
        region.center.longitude = (minLongitude + maxLongitude) / 2;
        region.span.latitudeDelta = (maxLatitude - minLatitude);
        region.span.longitudeDelta = (maxLongitude - minLongitude);
        success(polyline, region);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
    }];
}

@end
