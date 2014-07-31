//
//  VCLeftMenuViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLeftMenuViewController.h"
#import "VCRideViewController.h"
#import "VCInterfaceModes.h"
#import "VCRiderProfileViewController.h"
#import "VCMenuItemTableViewCell.h"

@interface VCLeftMenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation VCLeftMenuViewController

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int row = [indexPath row];
    UITableViewCell * cell;
    if (row == 0) {
       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        
        cell.textLabel.text = @"Profile";
    }
    else if (row == 1){
        VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        
        //cell.textLabel.text = @"Map";
        cell = menuItemTableViewCell;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ///setCenterViewControllers
    int row = [indexPath row];
    
    if (row == 0) {
        //TODO: Put Actual Profile In Here
        VCRiderProfileViewController * profileViewController = [[VCRiderProfileViewController alloc] init];
        [[VCInterfaceModes instance] setCenterViewControllers: @[profileViewController]];
        
    }
    else if (row == 1) {
        VCRideViewController * rideViewController = [[VCRideViewController alloc] init];
        [[VCInterfaceModes instance] setCenterViewControllers: @[rideViewController]];
        
    }
    
    
}

@end
