//
//  VCLocation.h
//  Voco
//
//  Created by Matthew Shultz on 6/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCGeoObject : NSObject

@property (nonatomic, strong) NSNumber * objectId;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;

+ (RKObjectMapping*) getMapping;

@end
