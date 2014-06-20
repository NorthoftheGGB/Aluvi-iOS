//
//  VCDriverCreateAccountVideoTutorialController.m
//  Voco
//
//  Created by Elliott De Aratanha on 6/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverVideoTutorialController.h"
@import MediaPlayer;

@interface VCDriverVideoTutorialController ()
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet UILabel *referralCodeLabel;


- (IBAction)segmentedControl:(id)sender;

- (IBAction)didTapFinish:(id)sender;

@end

@implementation VCDriverVideoTutorialController

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
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:@"https://s3-us-west-2.amazonaws.com/voco-development/flight_56_047489AA5D2B80_044D89AA5D2B80_F2CF0D00_47300E00_1393988868447.avi"]];
    player.view.frame = _videoContainer.frame;
    [self.view addSubview:_videoContainer];
    [player play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentedControl:(id)sender {
}

- (IBAction)didTapFinish:(id)sender {
    [UIAlertView showWithTitle:@"Registered!"
                       message:@"Thank you for completing driver registration, Voco will contact you to complete your activation"
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [self.navigationController popViewControllerAnimated:YES];

    }];
}
@end
