//
//  VCCarInfoViewController.m
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCCarInfoViewController.h"
#import "VCStyle.h"

@interface VCCarInfoViewController ()
@property (strong, nonatomic) IBOutlet UITextField *liscencePlateField;
@property (strong, nonatomic) IBOutlet UITextField *carInfoField;


- (IBAction)liscencePlateFieldDidEndOnExit:(id)sender;
- (IBAction)carInfoFieldDidEndOnExit:(id)sender;
- (IBAction)didTapSave:(id)sender;



@end

@implementation VCCarInfoViewController



- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

-(void)viewDidLoad{
    
    [self setGradient];
}


- (IBAction)liscencePlateFieldDidEndOnExit:(id)sender {
}

- (IBAction)carInfoFieldDidEndOnExit:(id)sender {
}

- (IBAction)didTapSave:(id)sender {
}
@end
