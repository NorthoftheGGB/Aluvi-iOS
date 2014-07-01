//
//  MQBoundingBox.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQCoordinate : NSObject

@property (nonatomic, strong) NSNumber * lng;
@property (nonatomic, strong) NSNumber * lat;

+ (RKObjectMapping *) getMapping;

@end


@interface MQBoundingBox : NSObject

@property (nonatomic, strong) MQCoordinate * ul;
@property (nonatomic, strong) MQCoordinate * lr;

+ (RKObjectMapping *) getMapping;

@end
