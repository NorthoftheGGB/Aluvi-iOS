//
//  VCTermsOfServiceViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 9/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTermsOfServiceViewController.h"


@interface VCTermsOfServiceViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation VCTermsOfServiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Aluvi-TOS" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:nil];
    [[_webView scrollView] setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
     */
   
}

- (void) viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) didTapDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
