//
//  VCLogin.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCLogin : NSObject

@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * password;

+ (RKObjectMapping *)getMapping;

@end
