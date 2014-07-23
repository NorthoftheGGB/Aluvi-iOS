//
//  VCEditLocationWidget.m
//  Voco
//
//  Created by Matthew Shultz on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCEditLocationWidget.h"
#import "VCLabel.h"
#import "VCTextField.h"
#import "VCLocationSearchViewController.h"

@interface VCEditLocationWidget () <VCLocationSearchViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *editView;
@property (strong, nonatomic) IBOutlet UIView *displayView;
@property (strong, nonatomic) IBOutlet VCTextField *editTextField;
@property (strong, nonatomic) IBOutlet VCLabel *locationTypeLabel;
@property (strong, nonatomic) IBOutlet VCLabel *locationNameLabel;

- (IBAction)didTapLocationText:(id)sender;

@end

@implementation VCEditLocationWidget

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setMode:(NSInteger)mode {
    _mode = mode;
    
    [self showInterfaceForMode];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showInterfaceForMode];
    
}

-(void) showInterfaceForMode {
    
    if(_mode == kEditLocationWidgetDisplayMode){
        [self showDisplayMode];
    } else if (_mode == kEditLocationWidgetEditMode ){
        [self showEditMode];
    }
}

- (void) showDisplayMode {
    
    [UIView transitionWithView:self.view
                      duration:.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [_editView removeFromSuperview];
                        [self.view addSubview:_displayView];
                    } completion:^(BOOL finished) {
                        
                    } ];

}

- (void) showEditMode {
    
    [UIView transitionWithView:self.view
                      duration:.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [_displayView removeFromSuperview];
                        [self.view addSubview:_editView];
                    } completion:^(BOOL finished) {
                        
                    } ];
}

- (void) setLocationText: (NSString *) text {
    _editTextField.text = text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)e:(id)sender {
    VCLocationSearchViewController * vc = [[VCLocationSearchViewController alloc] init];
    vc.delegate = self;
    [self.navigationController presentViewController:vc animated:YES completion:nil];

}


- (IBAction)didTapLocationText:(id)sender {
    VCLocationSearchViewController * vc = [[VCLocationSearchViewController alloc] init];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}
@end
