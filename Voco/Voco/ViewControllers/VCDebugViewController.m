//
//  VCDebugViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDebugViewController.h"
#import "VCApi.h"
#import "VCDriverApi.h"
#import "VCInterfaceManager.h"
#import "VCDialogs.h"

@interface VCDebugViewController ()

@end

@implementation VCDebugViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doIt:(id)sender {
    
    [[VCInterfaceManager instance] showRiderInterface];

}

- (IBAction)exitDebugHelper:(id)sender {
    [[VCInterfaceManager instance] showInterface];
}

@end
