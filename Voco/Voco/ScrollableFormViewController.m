//
//  BaseViewController.m
//  joinman
//
//  Created by Matthew Shultz on 4/12/13.
//
//

#import "ScrollableFormViewController.h"

@interface ScrollableFormViewController () {
    CGSize lastKeyboardSize;
}

@end

@implementation ScrollableFormViewController

@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setScrollViewTextFieldDelegates: self.scrollView];
    
}

- (void) setScrollViewTextFieldDelegates:(UIView *) view {
    for( id v in view.subviews){
        if([v isKindOfClass:[UITextField class]] ){
            [(UITextField *) v setDelegate: self];
        } else if([v isKindOfClass:[UIView class]]){
            [self setScrollViewTextFieldDelegates:v];
        }
        
    }
}


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) focusActiveView: (CGSize) keyboardSize {
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    int toolBarHeight = 0;
    aRect.size.height -= toolBarHeight;
    aRect.size.height -= self.scrollView.frame.origin.y; //For the toolbar
    // 2nd term relates to the placement of the scrollView in the main view
    // aRect now should contain the viewable area (not covered by the keyboard_ of the main view
    
    if(_activeView == nil){
        NSLog(@"%@", @"ERROR: Active view in nil!");
    }
    CGRect viewRect = _activeView.frame; //the rect of the activeView, should be the table view cell
    int scrollTargetY = viewRect.origin.y + viewRect.size.height; //moving the origin down
    int heightThreshold = aRect.size.height - toolBarHeight;
    
    // NOTE: These calculations work for scrollviews that are flush with the top of the screen
    //       But, these calculations need to be extended to work with scrollviews that are not
    //       flush with the bottom of the screen.
    
    if (!CGRectContainsPoint(aRect, CGPointMake(0.0,scrollTargetY)) ) {
        CGPoint scrollPoint = CGPointMake(0.0, scrollTargetY - heightThreshold );
        [scrollView setContentOffset:scrollPoint animated:YES];
    }

}

#pragma mark Keyboard
- (void)keyboardWasShown:(NSNotification *)notification
{
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    lastKeyboardSize = keyboardSize;
    [self focusActiveView:keyboardSize];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    [self resetContentInsets];
    
}

- (void) resetContentInsets {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //Editable field must be in cell by itself for this to work properly
    if([self.scrollView isKindOfClass:[UITableView class]]
       ){
        self.activeView = textField.superview.superview;
    } else {
        self.activeView = textField;
    }
    
    [self focusActiveView:lastKeyboardSize];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeView = nil;
}


- (IBAction) didEndOnExit:(id) sender {
    [self.activeView resignFirstResponder];
}

@end
