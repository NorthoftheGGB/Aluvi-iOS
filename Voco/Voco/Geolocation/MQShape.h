//
//  MQShape.h
//  Voco
//
//  Created by Matthew Shultz on 6/12/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQShape : NSObject

@property(nonatomic, strong) NSArray * maneuverIndexes;
@property(nonatomic, strong) NSArray * shapePoints;
@property(nonatomic, strong) NSArray * legIndexes;

+ (RKObjectMapping *) getMapping;

@end
