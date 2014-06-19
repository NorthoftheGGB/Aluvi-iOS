//
//  VCDriverCreateAccountVideoTutorialController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverCreateAccountVideoTutorialController.h"

@interface VCDriverCreateAccountVideoTutorialController ()
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet UILabel *referralCodeLabel;


- (IBAction)segmentedControl:(id)sender;

- (IBAction)didTapFinish:(id)sender;

@end

@implementation VCDriverCreateAccountVideoTutorialController

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

- (IBAction)segmentedControl:(id)sender {
}

- (IBAction)didTapFinish:(id)sender {
}
@end
