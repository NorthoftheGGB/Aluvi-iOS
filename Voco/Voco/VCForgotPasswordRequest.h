//
//  VCForgotPasswordRequest.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCForgotPasswordRequest : NSObject

@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * phone;

+ (RKObjectMapping *)getMapping;

@end
