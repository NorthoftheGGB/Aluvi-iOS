//
//  VCNameTextField.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCNameTextField.h"
#import "US2Validator.h"
#import "US2ConditionAlphabetic.h"


@implementation VCNameTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        US2ConditionAlphabetic *firstNameCondition =[[US2ConditionAlphabetic alloc] init];
        US2Validator *validator = [[US2Validator alloc] init];
        [validator addCondition:firstNameCondition];
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
