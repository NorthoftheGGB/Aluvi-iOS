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
#import "VCMenuUserInfoTableViewCell.h"
#import "VCMenuDriverClockOnTableViewCell.h"
#import "VCSubMenuItemTableViewCell.h"


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

@property (nonatomic) NSUInteger selectedCellTag;
@end

@implementation VCLeftMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tableCellList = [NSMutableArray arrayWithArray: @[kUserInfoCell, kProfileCell, kScheduleCell, kMapCell, kPaymentCell, kReceiptsCell, kSupportCell, kModeCell ]];
        _selectedCellTag = -1;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    long row = [indexPath row];
    
    int height = 45; // default
    switch([[_tableCellList objectAtIndex:row] integerValue]){
            
        case kUserInfoCellInteger:
            height = 200;
            break;
            
        case kProfileCellInteger:
            height = 100;
            break;

    }
    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    long row = [indexPath row];
    UITableViewCell * cell;
    
    long tag = [[_tableCellList objectAtIndex:row] integerValue];
    switch(tag){
        
        case kUserInfoCellInteger:
        { VCMenuUserInfoTableViewCell * menuUserInfoCell = [WRUtilities getViewFromNib:@"VCMenuUserInfoTableViewCell" class:[VCMenuUserInfoTableViewCell class]];
            
            //TODO: This is a placeholder image, replace it with relevant string!
            
            menuUserInfoCell.userImageView.image = [UIImage imageNamed: @"user-image-small"];
            
            //TODO: This is a placeholder name, replace it with relevant string!
            
            menuUserInfoCell.userFullName.text = @"Devon Drakesbad";
            cell = menuUserInfoCell;
        }
            break;
            
        case kProfileCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-profile-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Profile";
            cell = menuItemTableViewCell;
        }
            break;
            
        case kScheduleCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-schedule-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Schedule";
            cell = menuItemTableViewCell;
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
            
        case kMapCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-map-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Map";
            cell = menuItemTableViewCell;
        }
            break;
            
        case kPaymentCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-payments-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Payment Settings";
            cell = menuItemTableViewCell;
        }
            break;
            
        case kReceiptsCellInteger:
        {VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-receipts-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Receipts";
            cell = menuItemTableViewCell;
        }
            break;
            
        case kSupportCellInteger:
        {VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-support-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Support";
            cell = menuItemTableViewCell;
        }
            break;
            
       /* case kModeCellInteger:
        {VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-map-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Map";
            cell = menuItemTableViewCell;
        }
            break;*/
            
            
           }
    
    if( tag == _selectedCellTag ){
        if([cell isKindOfClass:[VCMenuItemTableViewCell class]]) {
            [(VCMenuItemTableViewCell*) cell deselect];
        }
        else if([cell isKindOfClass:[VCSubMenuItemTableViewCell class]]){
            [(VCSubMenuItemTableViewCell*) cell deselect];
        }
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[VCMenuItemTableViewCell class]]) {
        [(VCMenuItemTableViewCell*) cell deselect];
    }
    else if([cell isKindOfClass:[VCSubMenuItemTableViewCell class]]){
        [(VCSubMenuItemTableViewCell*) cell deselect];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // setCenterViewControllers
    long row = [indexPath row];
    
 
    long tag = [[_tableCellList objectAtIndex:row] integerValue];
    switch(tag){
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
    
    _selectedCellTag = tag;
    
    
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
