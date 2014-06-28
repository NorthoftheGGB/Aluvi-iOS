//
//  VCEmailTextField.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCEmailTextField.h"
#import "US2ConditionEmail.h"
#import "US2Validator.h"

@implementation VCEmailTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.fieldName = @"Email";
        
        US2ConditionEmail *emailCondition = [[US2ConditionEmail alloc] init];
        US2Validator *validator = [[US2Validator alloc] init];
        [validator addCondition:emailCondition];
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
