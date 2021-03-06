//
//  VCDriverInterestedRequest.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCDriverInterestedRequest : NSObject

@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * region;
@property (nonatomic, strong) NSString * driverReferralCode;

+ (RKObjectMapping *)getMapping;

@end
