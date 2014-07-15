//
//  VCDriversLicenseTextField.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/13/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriversLicenseTextField.h"
#import "US2Validator.h"
#import "US2ConditionAlphanumeric.h"
#import "US2ConditionRange.h"

@implementation VCDriversLicenseTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.fieldName = @"Driver's License";
        
        US2Validator *validator = [[US2Validator alloc] init];
        
        US2ConditionAlphanumeric *driverLicenseCondition =[[US2ConditionAlphanumeric alloc] init];
        US2ConditionRange *rangeCondition = [[US2ConditionRange alloc] init];
        rangeCondition.range = NSMakeRange(6, 14);
        
        [validator addCondition:driverLicenseCondition];
        [validator addCondition:rangeCondition];
        self.validator = validator;
    
    //6-14, alpha numeric. CA - issues an 8 character alpha-numeric DL#
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
