//
//  VCProfile.h
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCProfile : NSObject <NSCoding>

@property(nonatomic, strong) NSNumber * carId;

@property(nonatomic, strong) NSString * firstName;
@property(nonatomic, strong) NSString * lastName;
@property(nonatomic, strong) NSString * phone;
@property(nonatomic, strong) NSString * email;
@property(nonatomic, strong) NSString * workEmail;

@property(nonatomic, strong) NSNumber * commuterRefillAmountCents;
@property(nonatomic, strong) NSNumber * commuterBalanceCents;
@property(nonatomic, strong) NSNumber * commuterRefillEnabled;

@property(nonatomic, strong) NSString * defaultCardToken;
@property(nonatomic, strong) NSString * cardLastFour;
@property(nonatomic, strong) NSString * cardBrand;

@property(nonatomic, strong) NSString * recipientCardBrand;
@property(nonatomic, strong) NSString * recipientCardLastFour;


@property(nonatomic, strong) NSString * bankAccountName;

@property(nonatomic, strong) NSString * smallImageUrl;
@property(nonatomic, strong) NSString * largeImageUrl;

+ (RKObjectMapping *) getMapping;

@end
