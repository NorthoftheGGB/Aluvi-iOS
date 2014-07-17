//
//  VCFare.h
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCFare : NSObject

@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) NSNumber * amount;
@property (nonatomic, strong) NSNumber * driverEarnings;

+ (void)createMappings:(RKObjectManager *)objectManager;

@end
