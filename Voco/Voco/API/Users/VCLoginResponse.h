//
//  VCTokenResponse.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCLoginResponse : NSObject

@property (nonatomic, strong) NSString * token;
@property (nonatomic, strong) NSString * driverState;
@property (nonatomic, strong) NSString * riderState;

+ (RKObjectMapping *)getMapping;

@end