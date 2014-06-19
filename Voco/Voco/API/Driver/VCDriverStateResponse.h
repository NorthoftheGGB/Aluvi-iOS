//
//  VCDriveStateResponse.h
//  Voco
//
//  Created by Matthew Shultz on 6/19/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCDriverStateResponse : NSObject

@property(nonatomic, strong) NSString * state;

+ (RKObjectMapping *)getMapping;

@end
