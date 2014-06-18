//
//  VCRequestIdentify.h
//  Voco
//
//  Created by Matthew Shultz on 6/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCRequestUpdate : NSObject

@property(nonatomic, strong) NSNumber * requestId;
@property(nonatomic, strong) NSString * event; // Currently unused

+  (void)createMappings:(RKObjectManager *)objectManager;

@end
