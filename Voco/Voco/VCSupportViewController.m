//
//  VCSupportViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/20/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCSupportViewController.h"



@interface VCSupportViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *sumbitButton;
- (IBAction)didTapSubmit:(id)sender;

@end

@implementation VCSupportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
}


- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)messageTextView
{
    messageTextView.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSubmit:(id)sender {
}
@end
