//
//  VCDriverRegistration.m
//  Voco
//
//  Created by Matthew Shultz on 6/19/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverRegistration.h"

@implementation VCDriverRegistration

+  (RKObjectMapping*) getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                 @"drivers_license_number" : @"driversLicenseNumber",
                                                 @"default_recipient_debit_card_token" : @"debitCardToken",
                                                 @"car_brand" : @"carBrand",
                                                 @"car_model" : @"carModel",
                                                 @"car_year" : @"carYear",
                                                 @"car_license_plate" : @"carLicensePlate",
                                                 @"referral_code" : @"referralCode"
                                                 }];
    return mapping;
}

@end
