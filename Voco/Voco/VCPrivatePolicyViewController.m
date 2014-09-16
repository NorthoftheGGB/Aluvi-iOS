//
//  VCPrivatePolicyViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 9/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCPrivatePolicyViewController.h"

@interface VCPrivatePolicyViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation VCPrivatePolicyViewController

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
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Aluvi-Privacy-Policy" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
