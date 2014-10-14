//
//  VCDriverRegistration.h
//  Voco
//
//  Created by Matthew Shultz on 6/19/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCDriverRegistration : NSObject

@property (nonatomic, strong) NSString * driversLicenseNumber;
@property (nonatomic, strong) NSString * debitCardToken;
@property (nonatomic, strong) NSString * carBrand;
@property (nonatomic, strong) NSString * carModel;
@property (nonatomic, strong) NSString * carYear;
@property (nonatomic, strong) NSString * carLicensePlate;
@property (nonatomic, strong) NSString * referralCode;

+  (RKObjectMapping*) getMapping;

@end
