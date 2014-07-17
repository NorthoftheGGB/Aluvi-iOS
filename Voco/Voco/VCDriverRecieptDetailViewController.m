//
//  VCDriverRecieptsDetailViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverRecieptDetailViewController.h"

@interface VCDriverRecieptDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *recieptDetailTextView;

@end

@implementation VCDriverRecieptDetailViewController

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

@end
