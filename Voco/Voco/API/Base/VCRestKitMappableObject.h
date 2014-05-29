//
//  VCRestKitMappableObject.h
//  Voco
//
//  Created by Matthew Shultz on 5/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>
#import "VCApi.h"

@protocol VCRestKitMappableObject <NSObject>

+ (void) createMappings: (RKObjectManager *) objectManager;

@end
