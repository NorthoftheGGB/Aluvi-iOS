//
//  VCPhoneTextField.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCPhoneTextField.h"
#import "US2Validator.h"
#import "US2ConditionNumeric.h"
#import "US2ConditionRange.h"

@implementation VCPhoneTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.fieldName = @"Phone Number";
        
        US2Validator *validator = [[US2Validator alloc] init];
        
        US2ConditionNumeric *numericCondition =[[US2ConditionNumeric alloc] init];
        US2ConditionRange *rangeCondition = [[US2ConditionRange alloc] init];
        rangeCondition.range = NSMakeRange(10, 10);
        
        [validator addCondition:numericCondition];
        [validator addCondition:rangeCondition];
        self.validator = validator;
        
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSString *) phoneNumberDigits {
    NSString * text = [super text];
    NSString * newString = [[text componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:text];
    return newString;
    
}

- (void) setText: (NSString *) text {
    // formatted the phone number
    NSString *formatted = [NSString stringWithFormat: @"(%@) %@-%@", [text substringWithRange:NSMakeRange(1,3)],[text substringWithRange:NSMakeRange(4,6)],
                           [text substringWithRange:NSMakeRange(7,10)]];
    [super setText:formatted];
}

@end
