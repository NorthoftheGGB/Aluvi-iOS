//
//  WRUtilities
//  WinterRoot LLC
//
//  Created by Matthew Shultz on 6/3/12.
//  Copyright (c) 2012 WinterRoot LLC. All rights reserved.
//

#import "WRUtilities.h"
#import "NSDate+Pretty.h"

static UIAlertView * criticalErrorView = nil;

@interface WRUtilities () <UIAlertViewDelegate>

@end

@implementation WRUtilities

+ (id)getViewFromNib: (NSString *) nibName class: (id) class {
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:nibName
                                                owner:nil options:nil];
    UIView * view;
    for (id object in bundle) {
        if ([object isKindOfClass:class])
            view = (UIView *)object;
    }
    assert(view != nil && "View can't be nil");
    return view;
    
}

+ (void) criticalError: (NSError *) error {
    
    NSLog(@"%@ Critical Error: %@", [[NSDate date] pretty], [error debugDescription]);
    
    if(criticalErrorView != nil){
        [criticalErrorView dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Critical Error"
                          message: [error debugDescription]
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    criticalErrorView = alert;
    [alert show];
    
}

+ (void) criticalErrorWithString: (NSString *) error {
    
    NSLog(@"%@ Critical Error: %@", [[NSDate date] pretty] , error);
    
    if(criticalErrorView != nil){
        [criticalErrorView dismissWithClickedButtonIndex:0 animated:NO];
        criticalErrorView = nil;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Critical Error"
                          message: error
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    criticalErrorView = alert;
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
}

+ (void) stateErrorWithString: (NSString *) error {
    
    NSLog(@"%@ Critical Error: %@", [[NSDate date] pretty] , error);
    
    if(criticalErrorView != nil){
        [criticalErrorView dismissWithClickedButtonIndex:0 animated:NO];
        criticalErrorView = nil;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Error"
                          message: error
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    criticalErrorView = alert;
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
}

+ (void) successMessage: (NSString *) message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    criticalErrorView = nil;
}
@end
