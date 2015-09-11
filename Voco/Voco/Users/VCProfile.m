//
//  VCProfile.m
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCProfile.h"
#import "VCApi.h"
#import "Car.h"

@implementation VCProfile

+ (RKObjectMapping *) getMapping {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"first_name" : @"firstName",
                                                  @"last_name" : @"lastName",
                                                  @"phone" : @"phone",
                                                  @"email" : @"email",
                                                  @"work_email" : @"workEmail",
                                                  @"commuter_refill_amount_cents" : @"commuterRefillAmountCents",
                                                  @"commuter_balance_cents" : @"commuterBalanceCents",
                                                  @"commuter_refill_enabled" : @"commuterRefillEnabled",
                                                  @"card_last_four" : @"cardLastFour",
                                                  @"card_brand" : @"cardBrand",
                                                  @"bank_account_name" : @"bankAccountName",
                                                  @"recipient_card_last_four" : @"recipientCardLastFour",
                                                  @"recipient_card_brand" : @"recipientCardBrand",
                                                  @"image_small" : @"smallImageUrl",
                                                  @"image_large" : @"largeImageUrl",
                                                  @"free_rides" : @"freeRides"
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
        _workEmail = [decoder decodeObjectForKey: @"workEmail"];
        _commuterRefillAmountCents = [decoder decodeObjectForKey: @"commuterRefillAmountCents"];
        _commuterBalanceCents = [decoder decodeObjectForKey: @"commuterBalanceCents"];
        _commuterRefillEnabled = [decoder decodeObjectForKey: @"commuterRefillEnabled"];
        _cardLastFour = [decoder decodeObjectForKey: @"cardLastFour"];
        _cardBrand = [decoder decodeObjectForKey: @"cardBrand"];
        _bankAccountName = [decoder decodeObjectForKey: @"bankAccountName"];
        _recipientCardBrand = [decoder decodeObjectForKey:@"recipient_card_brand"];
        _recipientCardLastFour = [decoder decodeObjectForKey:@"recipient_card_last_four"];
        _smallImageUrl = [decoder decodeObjectForKey:@"small_image"];
        _largeImageUrl = [decoder decodeObjectForKey:@"large_image"];
        _carId = [decoder decodeObjectForKey: @"carId"];
        _freeRides = [decoder decodeObjectForKey: @"freeRides"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: _firstName forKey: @"firstName"];
    [encoder encodeObject: _lastName forKey: @"lastName"];
    [encoder encodeObject: _phone forKey: @"phone"];
    [encoder encodeObject: _email forKey: @"email"];
    [encoder encodeObject: _workEmail forKey: @"workEmail"];
    [encoder encodeObject: _commuterRefillAmountCents forKey: @"commuterRefillAmountCents"];
    [encoder encodeObject: _commuterBalanceCents forKey: @"commuterBalanceCents"];
    [encoder encodeObject: _commuterRefillEnabled forKey: @"commuterRefillEnabled"];
    [encoder encodeObject: _cardLastFour forKey: @"cardLastFour"];
    [encoder encodeObject: _cardBrand forKey: @"cardBrand"];
    [encoder encodeObject: _bankAccountName forKey: @"bankAccountName"];
    [encoder encodeObject: _recipientCardBrand forKey:@"recipient_card_brand"];
    [encoder encodeObject: _recipientCardLastFour forKey:@"recipient_card_last_four"];
    [encoder encodeObject: _smallImageUrl forKey:@"small_image"];
    [encoder encodeObject: _largeImageUrl forKey:@"large_image"];
    [encoder encodeObject: _carId forKey:@"carId"];
    [encoder encodeObject: _freeRides forKey:@"freeRides"];
}
@end
