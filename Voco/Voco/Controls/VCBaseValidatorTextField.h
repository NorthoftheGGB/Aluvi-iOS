//
//  VCBaseValidatorTextField.h
//  Voco
//
//  Created by Matthew Shultz on 6/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "US2ValidatorTextField.h"

@interface VCBaseValidatorTextField : US2ValidatorTextField

@property(nonatomic, strong) NSString * fieldName;

- (US2ConditionCollection *) checkConditions;
- (BOOL) validate;

@end
