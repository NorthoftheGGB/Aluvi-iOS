//
//  BaseViewController.h
//  Voco
//
//  Created by Matthew Shultz on 4/12/13.
//
//

#import <UIKit/UIKit.h>

@interface VCScrollableFormViewController : UIViewController < UITextFieldDelegate >


@property(strong, nonatomic) IBOutlet UIScrollView * scrollView;
@property(strong, nonatomic) UIView * activeView;


- (void) setScrollViewTextFieldDelegates:(UIView *) view;
- (IBAction) didEndOnExit:(id) sender;

@end
