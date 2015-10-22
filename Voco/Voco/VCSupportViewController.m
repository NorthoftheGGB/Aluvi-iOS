//
//  VCSupportViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/20/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCSupportViewController.h"
#import <MBProgressHUD.h>
#import "VCApi.h"
#import "VCStyle.h"
#import "VCUsersApi.h"
#import "VCDebug.h"

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

- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setGradient];
    
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

- (void) didTapHamburger {
    [self dismissKeyboard:self];
    [super didTapHamburger];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)didTapSubmit:(id)sender {
    [self.view endEditing:YES];
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [VCUsersApi createSupportRequest:_messageTextView.text
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 hud.hidden = YES;
                                 [UIAlertView showWithTitle:@"Submitted" message:@"We will contact you shortly" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 hud.hidden = YES;
                                 [UIAlertView showWithTitle:@"Errors" message:@"There was a problem submitting your support request" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                             }];
    
}

- (IBAction)didTapTriageMode:(id)sender {
    [VCDebug showTriage];
}


@end
