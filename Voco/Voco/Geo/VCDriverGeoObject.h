//
//  VCDriverGeoObject.h
//  Voco
//
//  Created by Matthew Shultz on 7/15/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCDriverGeoObject : NSObject

@property (nonatomic, strong) NSNumber * objectId;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSNumber * currentFareCost;
@property (nonatomic, strong) NSNumber * currentFareId;

+ (RKObjectMapping*)getMapping;

@end
