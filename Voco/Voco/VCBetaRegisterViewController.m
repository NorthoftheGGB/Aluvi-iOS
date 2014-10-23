//
//  VCBetaRegisterViewController.m
//  Voco
//
//  Created by Matthew Shultz on 10/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCBetaRegisterViewController.h"

@interface VCBetaRegisterViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)didTapDone:(id)sender;

@end

@implementation VCBetaRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"SignUp" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:nil];

    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didTapDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
