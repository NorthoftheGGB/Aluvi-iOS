//
//  VCDebugViewController.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDebugViewController.h"
#import "VCDriverApi.h"
#import "VCInterfaceModes.h"

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
    [VCDriverApi loadDriveDetails:[NSNumber numberWithInt:404] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

    }];
}

- (IBAction)exitDebugHelper:(id)sender {
    [VCInterfaceModes showInterface];
}

@end
