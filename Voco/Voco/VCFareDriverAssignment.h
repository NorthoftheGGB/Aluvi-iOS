//
//  VCRideDriverAssignment.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRestKitMappableObject.h"

@interface VCFareDriverAssignment : NSObject

@property (nonatomic, strong) NSNumber * fareId;

+ (RKObjectMapping*) getMapping;

@end
