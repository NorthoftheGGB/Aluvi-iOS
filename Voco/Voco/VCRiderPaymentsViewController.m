//
//  VCRiderPaymentsViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderPaymentsViewController.h"
#import "VCTextField.h"


@interface VCRiderPaymentsViewController ()
@property (weak, nonatomic) IBOutlet VCTextField *cardNumberField;
@property (weak, nonatomic) IBOutlet VCTextField *expDateField;
@property (weak, nonatomic) IBOutlet VCTextField *cvsField;
@property (weak, nonatomic) IBOutlet VCTextField *zipCodeField;

@property (weak, nonatomic) IBOutlet UITableView *recieptListTableView;



- (IBAction)didTapUpdate:(id)sender;

@end

@implementation VCRiderPaymentsViewController

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
    self.title = @"Payments";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapUpdate:(id)sender {
}
@end
