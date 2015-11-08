//
//  AccelerationDetector.h
//  GyrosAndAccelerometers
//
//  Created by Matthew Shultz on 3/7/15.
//  Copyright (c) 2015 Joe Hoffman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AccelerationDetectorDelegate <NSObject>

@end

@interface AccelerationDetector : NSObject

@property id<AccelerationDetectorDelegate> delegate;

+ (AccelerationDetector *) instance;

@end
