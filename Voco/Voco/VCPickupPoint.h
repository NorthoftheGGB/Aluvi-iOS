//
//  VCPickupPoint.h
//  Voco
//
//  Created by matthewxi on 8/12/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface VCPickupPoint : NSObject

@property (nonatomic, strong) CLLocation * location;
@property (nonatomic, strong) NSNumber * numberOfRiders;

+ (RKObjectMapping *) getMapping;

@end
