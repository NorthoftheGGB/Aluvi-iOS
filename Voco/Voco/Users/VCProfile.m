//
//  VCProfile.m
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCProfile.h"
#import "VCApi.h"

@implementation VCProfile

+ (RKObjectMapping *) getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"first_name" : @"firstName",
                                                  @"last_name" : @"lastName",
                                                  @"phone" : @"phone",
                                                  @"email" : @"email",
                                                  @"default_card_token" : @"defaultCardToken",
                                                  @"commuter_refill_amount_cents" : @"commuterRefillAmountCents",
                                                  @"commuter_balance_cents" : @"commuterBalanceCents",
                                                  @"commuter_refill_enabled" : @"commuterRefillEnabled",
                                                  @"card_last_four" : @"cardLastFour",
                                                  @"card_brand" : @"cardBrand",
                                                  @"bank_account_name" : @"bankAccountName"
                                                  }];
    
    return mapping;
       
}

@end
