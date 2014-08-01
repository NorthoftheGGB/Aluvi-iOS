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

// These ones go in the array
#define kUserInfoCell @1000
#define kProfileCell @1001
#define kScheduleCell @1002
#define kScheduleItemCell @1003
#define kMapCell @1004
#define kPaymentCell @1005
#define kReceiptsCell @1006
#define kSupportCell @1007
#define kModeCell @1008

// These are used in the switch statement
#define kUserInfoCellInteger 1000
#define kProfileCellInteger 1001
#define kScheduleCellInteger 1002
#define kScheduleItemCellInteger 1003
#define kMapCellInteger 1004
#define kPaymentCellInteger 1005
#define kReceiptsCellInteger 1006
#define kSupportCellInteger 1007
#define kModeCellInteger 1008

@interface VCLeftMenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray * tableCellList;
@end

@implementation VCLeftMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tableCellList = [NSMutableArray arrayWithArray: @[kUserInfoCell, kProfileCell, kScheduleCell, kMapCell ]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableCellList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    long row = [indexPath row];
    UITableViewCell * cell;
    
    switch([[_tableCellList objectAtIndex:row] integerValue]){
        case kProfileCellInteger:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
            cell.textLabel.text = @"Profile";
        }
            break;
            
        case kMapCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-map-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Map";
            cell = menuItemTableViewCell;
        }
            break;
        case kScheduleCellInteger:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
            cell.textLabel.text = @"Schedule";
        }
            break;
        case kScheduleItemCellInteger:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
            cell.textLabel.text = @"Schedule Item";
        }
            break;

        default:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
            cell.textLabel.text = @"Not Configured";
        }
            break;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[VCMenuItemTableViewCell class]]) {
        [(VCMenuItemTableViewCell*) cell deselect];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // setCenterViewControllers
    long row = [indexPath row];
    
 
    switch([[_tableCellList objectAtIndex:row] integerValue]){
        case kProfileCellInteger:
        {
            //TODO: Put Actual Profile In Here
            VCRiderProfileViewController * profileViewController = [[VCRiderProfileViewController alloc] init];
            [[VCInterfaceModes instance] setCenterViewControllers: @[profileViewController]];
        }
            break;
            
        case kMapCellInteger:
        {
            VCRideViewController * rideViewController = [[VCRideViewController alloc] init];
            [[VCInterfaceModes instance] setCenterViewControllers: @[rideViewController]];
            
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
        }
            break;
            
        case kScheduleCellInteger:
        {
            if(![_tableCellList containsObject:kScheduleItemCell]){
                [self showScheduleItems];
            }
        }
        default:
            //do nothing
            break;
    }
    
    
    if( [[_tableCellList objectAtIndex:row] integerValue] != kScheduleCellInteger
       && [[_tableCellList objectAtIndex:row] integerValue] != kScheduleItemCellInteger
       && [_tableCellList containsObject:kScheduleItemCell]
       ){
        [self hideScheduleItems];
    }
    
    
    
}

- (void) showScheduleItems {
    long index = [_tableCellList indexOfObject:kScheduleCell];
    NSArray * scheduleItemsList = @[kScheduleItemCell, kScheduleItemCell, kScheduleItemCell];
    NSRange range;
    range.location = index + 1;
    range.length = [scheduleItemsList count];
    [_tableCellList insertObjects:scheduleItemsList atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    [_tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow: index+1 inSection:0],
                                          [NSIndexPath indexPathForRow: index+2 inSection:0],
                                          [NSIndexPath indexPathForRow: index+3 inSection:0]
                                          ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) hideScheduleItems {
    long index = [_tableCellList indexOfObject:kScheduleCell];
    NSArray * scheduleItemsList = @[kScheduleItemCell, kScheduleItemCell, kScheduleItemCell];
    NSRange range;
    range.location = index + 1;
    range.length = [scheduleItemsList count];
    [_tableCellList removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    [_tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow: index+1 inSection:0],
                                          [NSIndexPath indexPathForRow: index+2 inSection:0],
                                          [NSIndexPath indexPathForRow: index+3 inSection:0]
                                          ] withRowAnimation:UITableViewRowAnimationAutomatic];

}

@end
