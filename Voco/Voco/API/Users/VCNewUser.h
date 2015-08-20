//
//  VCNewUser.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCNewUser : NSObject

@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * referralCode;
@property (nonatomic, strong) NSNumber * driver;

+ (RKObjectMapping *)getMapping;

@end

