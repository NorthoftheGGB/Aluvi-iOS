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

@implementation VCPhoneTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.fieldName = @"Phone Number";
        
        US2ConditionNumeric *phoneNumberCondition =[[US2ConditionNumeric alloc] init];
        US2Validator *validator = [[US2Validator alloc] init];
        [validator addCondition:phoneNumberCondition];
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

@end
