//
//  VCUtilities.m
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCUtilities.h"

@implementation VCUtilities

+ (NSString *) formatCurrencyFromCents: (NSNumber *) cents {
    
    NSDecimalNumber * decimalNumber = [NSDecimalNumber decimalNumberWithMantissa:[cents integerValue]
                                                                        exponent:-2
                                                                      isNegative:NO];
  
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    return [formatter stringFromNumber:decimalNumber];
}

+ (NSDate *) beginningOfToday {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDateComponents * components = [calendar components:preservedComponents fromDate:date];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    date = [calendar dateFromComponents:components];
    return date;
}

@end
