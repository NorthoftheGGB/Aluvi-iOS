//
//  VCBaseValidatorTextField.m
//  Voco
//
//  Created by Matthew Shultz on 6/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCBaseValidatorTextField.h"
#import "US2Validator.h"

@implementation VCBaseValidatorTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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


- (BOOL) validate {
    if(!self.isValid){
        self.backgroundColor = [UIColor redColor];
        US2ConditionCollection * collection = [self checkConditions];
        US2Condition * condition =[collection conditionAtIndex:0];
        [self showFormErrorAlertView:_fieldName violation:condition.localizedViolationString];
        return NO;
    } else {
        return YES;
    }

}

- (US2ConditionCollection *) checkConditions {
    return [self.validator checkConditions:self.text];
}


- (void) showFormErrorAlertView: (NSString *) field violation:(NSString *) violdation {
    [UIAlertView showWithTitle:[NSString stringWithFormat:@"Invalid %@", field]  message:violdation cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
}

@end
