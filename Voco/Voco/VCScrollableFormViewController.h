//
//  BaseViewController.h
//  Voco
//
//  Created by Matthew Shultz on 4/12/13.
//
//

#import <UIKit/UIKit.h>
#import "VCCenterViewBaseViewController.h"
@interface VCScrollableFormViewController : VCCenterViewBaseViewController < UITextFieldDelegate >


@property(strong, nonatomic) IBOutlet UIScrollView * scrollView;
@property(strong, nonatomic) UIView * scrollFocusView;


- (void) setScrollViewTextFieldDelegates:(UIView *) view;
- (IBAction) didEndOnExit:(id) sender;

@end
