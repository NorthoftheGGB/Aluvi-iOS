//
//  VCMapQuestRouteResponse.h
//  Voco
//
//  Created by Matthew Shultz on 6/12/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQShape.h"

@interface MQRouteResponse : NSObject

@property (nonatomic, strong) MQShape * shape;

+ (RKObjectMapping *) getMapping;

@end
