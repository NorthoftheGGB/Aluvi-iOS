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
    
    _textView.attributedText = _termsOfServiceString;
    
   
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
