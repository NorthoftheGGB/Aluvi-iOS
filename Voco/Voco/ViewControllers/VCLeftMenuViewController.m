//
//  VCLeftMenuViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLeftMenuViewController.h"
#import "VCTicketViewController.h"
#import "VCDriveViewController.h"
#import "VCInterfaceManager.h"
#import "VCProfileViewController.h"
#import "VCSupportViewController.h"
#import "VCPaymentsViewController.h"
#import "VCReceiptsViewController.h"
#import "VCMenuItemTableViewCell.h"
#import "VCMenuUserInfoTableViewCell.h"
#import "VCMenuDriverClockOnTableViewCell.h"
#import "VCSubMenuItemTableViewCell.h"
#import "VCMenuItemNotConfiguredTableViewCell.h"
#import "VCMenuItemModeTableViewCell.h"
#import "NSDate+Pretty.h"
#import "VCUserStateManager.h"
#import "VCRiderApi.h"


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
#define kDriverSettingsCell @1009
#define kMyCarCell @1010
#define kEarningsCell @1011
#define kFareReceiptsCell @1012

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
#define kDriverSettingsInteger 1009
#define kMyCarCellInteger 1010
#define kEarningsCellInteger 1011
#define kFareReceiptsCellInteger 1012


@interface VCLeftMenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray * tableCellList;
@property (nonatomic, strong) NSArray * scheduleItems;
@property (nonatomic, strong) NSMutableArray * scheduleItemsList;
@property (nonatomic) NSInteger notificationCount;

@property (nonatomic) NSUInteger selectedCellTag;
@end

@implementation VCLeftMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        if([[VCUserStateManager instance] isHovDriver]){
            _tableCellList = [NSMutableArray arrayWithArray: @[kUserInfoCell, kScheduleCell, kMapCell, kDriverSettingsCell, kPaymentCell, kReceiptsCell, kSupportCell ]];
            
        } else {
            _tableCellList = [NSMutableArray arrayWithArray: @[kUserInfoCell, kScheduleCell, kMapCell, kPaymentCell, kReceiptsCell, kSupportCell ]];
        }
        _selectedCellTag = -1;
        
        [self countNotificaitons];

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
    [self countNotificaitons];
    [_tableView reloadData];
}

- (void) countNotificaitons {
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"savedState IN %@ AND confirmed = %@", @[kScheduledState], [NSNumber numberWithBool:NO]];
    [fetch setPredicate:predicate];
    NSError * error;
    NSArray * pending = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
    if(pending == nil){
        [WRUtilities criticalError:error];
    }
    _notificationCount = [pending count];
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
        {
            VCMenuUserInfoTableViewCell * menuUserInfoCell = [WRUtilities getViewFromNib:@"VCMenuUserInfoTableViewCell" class:[VCMenuUserInfoTableViewCell class]];
            
            //TODO: This is a placeholder image, replace it with relevant string!
            
            menuUserInfoCell.userImageView.image = [UIImage imageNamed: @"user-image-small"];
            
            //TODO: This is a placeholder name, replace it with relevant string!
            
            menuUserInfoCell.userFullName.text = [NSString stringWithFormat: @"%@ %@",
                                                  [[VCUserStateManager instance] profile].firstName,
                                                  [[VCUserStateManager instance] profile].lastName
                                                  ];
            menuUserInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuUserInfoCell;
        }
            break;
            
        /*case kProfileCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-profile-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Profile";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;
        }
            break;*/
            
        case kScheduleCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-schedule-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Schedule";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(_notificationCount > 0) {
                menuItemTableViewCell.badgeView.hidden = NO;
                menuItemTableViewCell.badgeNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)_notificationCount];
            } else {
                menuItemTableViewCell.badgeView.hidden = YES;

            }
            cell = menuItemTableViewCell;
        }
            break;
            
        case kScheduleItemCellInteger:
        {
            VCSubMenuItemTableViewCell * subMenuItemTableViewCell = [WRUtilities getViewFromNib:@"VCSubMenuItemTableViewCell" class:[VCSubMenuItemTableViewCell class]];
            
            long scheduleCellIndex = [_tableCellList indexOfObject:kScheduleCell];
            Ticket * ride = [_scheduleItems objectAtIndex:row-scheduleCellIndex-1];
            subMenuItemTableViewCell.itemTitleLabel.text = [NSString stringWithFormat:@"%@ to %@", ride.originShortName, ride.destinationShortName];
            subMenuItemTableViewCell.itemDateLabel.text = [ride.pickupTime monthAndDay];
            subMenuItemTableViewCell.itemTimeLabel.text = [ride.pickupTime time];
            subMenuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell = subMenuItemTableViewCell;
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
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
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
            
        case kDriverSettingsInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-receipts-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Driver Settings";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;

        }
            break;
            
        case kMyCarCellInteger:
        {
            
        }
            break;
            
        case kEarningsCellInteger:
        {
            VCSubMenuItemTableViewCell * subMenuItemTableViewCell = [WRUtilities getViewFromNib:@"VCSubMenuItemTableViewCell" class:[VCSubMenuItemTableViewCell class]];
            subMenuItemTableViewCell.itemTitleLabel.text = @"Earnings";
            cell = subMenuItemTableViewCell;
        }
            break;
            
        case kFareReceiptsCellInteger:
        {
            VCSubMenuItemTableViewCell * subMenuItemTableViewCell = [WRUtilities getViewFromNib:@"VCSubMenuItemTableViewCell" class:[VCSubMenuItemTableViewCell class]];
            subMenuItemTableViewCell.itemTitleLabel.text = @"Fare Receipts";
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
        case kUserInfoCellInteger:
        {
            
            VCProfileViewController * profileViewController = [[VCProfileViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[profileViewController]];
        }
            break;
            
        case kMapCellInteger:
        {
            VCTicketViewController * rideViewController = [[VCTicketViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[rideViewController]];
            
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
        }
            break;
            
        case kScheduleCellInteger:
        {
            if(![_tableCellList containsObject:kScheduleItemCell]){
                [VCRiderApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    NSLog(@"%@", @"Refreshed Scheduled Rides");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"schedule_updated" object:self];
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                }];
                [self showScheduleItems];
                
                VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
                [cell select];
            }
        }
            break;
            
        case kScheduleItemCellInteger:
        {
            long scheduleCellIndex = [_tableCellList indexOfObject:kScheduleCell];
            Ticket * ticket = [_scheduleItems objectAtIndex:row-scheduleCellIndex-1];
            
            if([ticket.driving boolValue]) {
                VCTicketViewController * driveViewController = [[VCTicketViewController alloc] init];
                driveViewController.ticket = ticket;
                [[VCInterfaceManager instance] setCenterViewControllers: @[driveViewController]];
            } else {
                VCTicketViewController * rideViewController = [[VCTicketViewController alloc] init];
                rideViewController.ticket = ticket;
                [[VCInterfaceManager instance] setCenterViewControllers: @[rideViewController]];
            }
            VCSubMenuItemTableViewCell * cell = (VCSubMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
        }
            break;
            
        case kDriverSettingsInteger:
        {
            
            if(![_tableCellList containsObject:kEarningsCell]){

                long index = [_tableCellList indexOfObject:kDriverSettingsCell];
            
                NSMutableArray * indexPaths = [NSMutableArray array];
                [indexPaths addObject:[NSIndexPath indexPathForRow: index+1 inSection:0]];
                [indexPaths addObject:[NSIndexPath indexPathForRow: index+2 inSection:0]];
            
                [_tableCellList insertObject:kEarningsCell atIndex:index+1];
                [_tableCellList insertObject:kFareReceiptsCell atIndex:index+2];
            
                [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
                [cell select];
            }
        }
            break;
            
        case kPaymentCellInteger:
        {
            VCPaymentsViewController * vc = [[VCPaymentsViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[vc]];
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
        }
            break;
            
        case kReceiptsCellInteger:
        {
            VCReceiptsViewController * vc = [[VCReceiptsViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[vc]];
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
        }
            break;
        
        case kSupportCellInteger:
        {

            VCSupportViewController * supportViewController = [[VCSupportViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[supportViewController]];
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
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
    
    if( [[_tableCellList objectAtIndex:row] integerValue] != kDriverSettingsInteger
       && [[_tableCellList objectAtIndex:row] integerValue] != kEarningsCellInteger
       && [[_tableCellList objectAtIndex:row] integerValue] != kFareReceiptsCellInteger
       && [_tableCellList containsObject:kEarningsCell]){
        
        long index = [_tableCellList indexOfObject:kDriverSettingsCell];
        NSRange range;
        range.location = index + 1;
        range.length = 2;
        [_tableCellList removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        NSMutableArray * indexPaths = [NSMutableArray array];
        for(int i=0; i<2; i++){
            [indexPaths addObject:[NSIndexPath indexPathForRow: index+i+1 inSection:0]];
        }
        [_tableView deleteRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    _selectedCellTag = tag;
    
    
}

- (void) loadScheduleItems {
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
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
    
 

}

- (void) showScheduleItems {
    [self loadScheduleItems];
    
    long index = [_tableCellList indexOfObject:kScheduleCell];
    NSRange range;
    range.location = index + 1;
    range.length = [_scheduleItemsList count];
    [_tableCellList insertObjects:_scheduleItemsList atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
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
