//
//  VCPasswordTextField.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCPasswordTextField.h"
#import "US2ConditionPasswordStrength.h"
#import "US2Validator.h"


@implementation VCPasswordTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.fieldName = @"Password";
        
        US2ConditionPasswordStrength *passwordCondition =[[US2ConditionPasswordStrength alloc] init];
        [passwordCondition setRequiredStrength:US2PasswordStrengthWeak];
        US2Validator *validator = [[US2Validator alloc] init];
        [validator addCondition:passwordCondition];
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
