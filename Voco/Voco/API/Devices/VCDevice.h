//
//  VCDevice.h
//  Voco
//
//  Created by Matthew Shultz on 5/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRestKitMappableObject.h"

@interface VCDevice : NSObject<VCRestKitMappableObject>

@property (nonatomic, strong) NSString * pushToken;

@end
