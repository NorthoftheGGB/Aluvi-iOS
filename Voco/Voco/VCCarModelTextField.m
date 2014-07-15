//
//  VCCarModelTextField.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/13/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCarModelTextField.h"
#import "US2Validator.h"
#import "US2ConditionAlphanumeric.h"
#import "US2ConditionRange.h"


@implementation VCCarModelTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
      self.fieldName = @"Car Model";
        
        US2Validator *validator = [[US2Validator alloc] init];
        US2ConditionAlphanumeric *carModelCondition =[[US2ConditionAlphanumeric alloc] init];
        
        [validator addCondition:carModelCondition];

        
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
