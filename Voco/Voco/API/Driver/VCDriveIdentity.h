//
//  VCDriveIdentity.h
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCDriveIdentity : NSObject

@property(nonatomic, strong) NSNumber * id;

+ (void)createMappings:(RKObjectManager *)objectManager;

@end
