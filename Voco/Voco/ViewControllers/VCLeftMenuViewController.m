//
//  VCLeftMenuViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLeftMenuViewController.h"
#import "VCRideViewController.h"
#import "VCInterfaceManager.h"
#import "VCRiderProfileViewController.h"
#import "VCMenuItemTableViewCell.h"
#import "VCMenuUserInfoTableViewCell.h"
#import "VCMenuDriverClockOnTableViewCell.h"
#import "VCSubMenuItemTableViewCell.h"
#import "VCMenuItemNotConfiguredTableViewCell.h"
#import "VCMenuItemModeTableViewCell.h"
#import "NSDate+Pretty.h"


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

//Drive



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
@property (nonatomic, strong) NSArray * scheduleItems;
@property (nonatomic, strong) NSMutableArray * scheduleItemsList;

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
    
    
    // Listen for notifications about updated rides
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleUpdated:) name:@"schedule_updated" object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) scheduleUpdated:(NSNotification *) notification {
    // just reload the table ?
    [self hideScheduleItems];
    [self showScheduleItems];
    [_tableView reloadData];
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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    long row = [indexPath row];
    
    int height = 44; // default
    switch([[_tableCellList objectAtIndex:row] integerValue]){
            
        case kUserInfoCellInteger:
            height = 116;
            break;
            
    }
    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    long row = [indexPath row];
    UITableViewCell * cell;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-bg@2x.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    long tag = [[_tableCellList objectAtIndex:row] integerValue];
    switch(tag){
            
        case kUserInfoCellInteger:
        { VCMenuUserInfoTableViewCell * menuUserInfoCell = [WRUtilities getViewFromNib:@"VCMenuUserInfoTableViewCell" class:[VCMenuUserInfoTableViewCell class]];
            
            //TODO: This is a placeholder image, replace it with relevant string!
            
            menuUserInfoCell.userImageView.image = [UIImage imageNamed: @"user-image-small"];
            
            //TODO: This is a placeholder name, replace it with relevant string!
            
            menuUserInfoCell.userFullName.text = @"Devon Drakesbad";
            menuUserInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuUserInfoCell;
        }
            break;
            
        case kProfileCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-profile-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Profile";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;
        }
            break;
            
        case kScheduleCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-schedule-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Schedule";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;
        }
            break;
            
        case kScheduleItemCellInteger:
        {
            VCSubMenuItemTableViewCell * subMenuItemTableViewCell = [WRUtilities getViewFromNib:@"VCSubMenuItemTableViewCell" class:[VCSubMenuItemTableViewCell class]];
            
            long scheduleCellIndex = [_tableCellList indexOfObject:kScheduleCell];
            Ride * ride = [_scheduleItems objectAtIndex:row-scheduleCellIndex-1];
            subMenuItemTableViewCell.itemTitleLabel.text = [NSString stringWithFormat:@"%@ to %@", ride.originShortName, ride.destinationShortName];
            subMenuItemTableViewCell.itemDateLabel.text = [ride.pickupTime monthAndDay];
            subMenuItemTableViewCell.itemTimeLabel.text = [ride.pickupTime time];
            subMenuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell = subMenuItemTableViewCell;
        }
            break;
            
        default:
        {
            VCMenuItemNotConfiguredTableViewCell * menuItemNotConfiguredTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemNotConfiguredTableViewCell" class:[VCMenuItemNotConfiguredTableViewCell class]];
            menuItemNotConfiguredTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemNotConfiguredTableViewCell;
        }
            break;
            
        case kMapCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-map-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Map";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;
        }
            break;
            
        case kPaymentCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-payments-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Payment Settings";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;
        }
            break;
            
        case kReceiptsCellInteger:
        {VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-receipts-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Receipts";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;
        }
            break;
            
        case kSupportCellInteger:
        {VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-support-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Support";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;
        }
            break;
            
            /* case kModeCellInteger:
             {VCMenuItemModeTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemModeTableViewCell" class:[VCMenuItemModeTableViewCell class]];
             menuItemTableViewCell.menuItemLabel.text = @"Driver Mode";
             menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            [[VCInterfaceManager instance] setCenterViewControllers: @[profileViewController]];
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
        }
            break;
            
        case kMapCellInteger:
        {
            VCRideViewController * rideViewController = [[VCRideViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[rideViewController]];
            
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
        }
            break;
            
        case kScheduleCellInteger:
        {
            if(![_tableCellList containsObject:kScheduleItemCell]){
                [self showScheduleItems];
                
                VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
                [cell select];
            }
        }
            break;
            
        case kScheduleItemCellInteger:
        {
            VCRideViewController * rideViewController = [[VCRideViewController alloc] init];
            long scheduleCellIndex = [_tableCellList indexOfObject:kScheduleCell];
            rideViewController.ride = [_scheduleItems objectAtIndex:row-scheduleCellIndex-1];
            [[VCInterfaceManager instance] setCenterViewControllers: @[rideViewController]];
            VCSubMenuItemTableViewCell * cell = (VCSubMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
        }
            break;
            
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

- (void) loadScheduleItems {
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ride"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"savedState IN %@ ", @[kCreatedState, kRequestedState, kScheduledState]];
    [fetch setPredicate:predicate];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"pickupTime" ascending:YES];
    [fetch setSortDescriptors:@[sort]];
    NSError * error;
    _scheduleItems = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
    _scheduleItemsList = [NSMutableArray array];
    for(int i=0; i<[_scheduleItems count]; i++){
        [_scheduleItemsList addObject:kScheduleItemCell];
    }
    
    long index = [_tableCellList indexOfObject:kScheduleCell];
    NSRange range;
    range.location = index + 1;
    range.length = [_scheduleItemsList count];
    [_tableCellList insertObjects:_scheduleItemsList atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];

}

- (void) showScheduleItems {
    [self loadScheduleItems];
    
    if([_scheduleItems count] > 0) {
        
        long index = [_tableCellList indexOfObject:kScheduleCell];
        NSMutableArray * indexPaths = [NSMutableArray array];
        for(int i=0; i<[_scheduleItems count]; i++){
            [indexPaths addObject:[NSIndexPath indexPathForRow: index+i+1 inSection:0]];
        }
        
       
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

- (void) hideScheduleItems {
    
    
    if([_scheduleItems count] > 0) {
        
        long index = [_tableCellList indexOfObject:kScheduleCell];
        NSRange range;
        range.location = index + 1;
        range.length = [_scheduleItemsList count];
        [_tableCellList removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        NSMutableArray * indexPaths = [NSMutableArray array];
        for(int i=0; i<[_scheduleItems count]; i++){
            [indexPaths addObject:[NSIndexPath indexPathForRow: index+i+1 inSection:0]];
        }
        [_tableView deleteRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    
}

@end
