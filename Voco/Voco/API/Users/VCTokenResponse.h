//
//  VCTokenResponse.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCTokenResponse : NSObject

@property (nonatomic, strong) NSString * token;

+ (RKObjectMapping *)getMapping;

@end
