//
//  MQRoute.h
//  Voco
//
//  Created by Matthew Shultz on 6/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQShape.h"
#import "MQBoundingBox.h"

@interface MQRoute : NSObject

@property(nonatomic, strong) MQShape * shape;
@property(nonatomic, strong) MQBoundingBox * boundingBox;

+ (RKObjectMapping *) getMapping;

@end
