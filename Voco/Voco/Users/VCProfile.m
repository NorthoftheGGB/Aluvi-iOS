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
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [self init]))
    {
        _firstName = [decoder decodeObjectForKey: @"firstName"];
        _lastName = [decoder decodeObjectForKey: @"lastName"];
        _phone = [decoder decodeObjectForKey: @"phone"];
        _email = [decoder decodeObjectForKey: @"email"];
        _commuterRefillAmountCents = [decoder decodeObjectForKey: @"commuterRefillAmountCents"];
        _commuterBalanceCents = [decoder decodeObjectForKey: @"commuterBalanceCents"];
        _commuterRefillEnabled = [decoder decodeObjectForKey: @"commuterRefillEnabled"];
        _defaultCardToken = [decoder decodeObjectForKey: @"defaultCardToken"];
        _cardLastFour = [decoder decodeObjectForKey: @"cardLastFour"];
        _cardBrand = [decoder decodeObjectForKey: @"cardBrand"];
        _bankAccountName = [decoder decodeObjectForKey: @"bankAccountName"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: _firstName forKey: @"firstName"];
    [encoder encodeObject: _lastName forKey: @"lastName"];
    [encoder encodeObject: _phone forKey: @"phone"];
    [encoder encodeObject: _email forKey: @"email"];
    [encoder encodeObject: _commuterRefillAmountCents forKey: @"commuterRefillAmountCents"];
    [encoder encodeObject: _commuterBalanceCents forKey: @"commuterBalanceCents"];
    [encoder encodeObject: _commuterRefillEnabled forKey: @"commuterRefillEnabled"];
    [encoder encodeObject: _defaultCardToken forKey: @"defaultCardToken"];
    [encoder encodeObject: _cardLastFour forKey: @"cardLastFour"];
    [encoder encodeObject: _cardBrand forKey: @"cardBrand"];
    [encoder encodeObject: _bankAccountName forKey: @"bankAccountName"];
}
@end
