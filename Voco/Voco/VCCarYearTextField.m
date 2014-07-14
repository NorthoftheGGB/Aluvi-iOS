//
//  VCCarYearTextField.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/13/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCarYearTextField.h"
#import "US2Validator.h"
#import "US2ConditionNumeric.h"
#import "US2ConditionRange.h"

@implementation VCCarYearTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.fieldName = @"Year";
        
        US2Validator *validator = [[US2Validator alloc] init];
        
        US2ConditionNumeric *numericCondition =[[US2ConditionNumeric alloc] init];
        US2ConditionRange *rangeCondition = [[US2ConditionRange alloc] init];
        rangeCondition.range = NSMakeRange(4, 4);
        
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

@end
