//
//  VCLeftMenuViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLeftMenuViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "VCTicketViewController.h"
#import "VCDriveViewController.h"
#import "VCInterfaceManager.h"
#import "VCProfileViewController.h"
#import "VCSupportViewController.h"
#import "VCPaymentsViewController.h"
#import "VCReceiptsViewController.h"
#import "VCEarningsViewController.h"
#import "VCFareReceiptsViewController.h"
#import "VCMenuItemTableViewCell.h"
#import "VCMenuUserInfoTableViewCell.h"
#import "VCMenuDriverClockOnTableViewCell.h"
#import "VCSubMenuItemTableViewCell.h"
#import "VCMenuItemNotConfiguredTableViewCell.h"
#import "VCMenuItemModeTableViewCell.h"
#import "VCDriverSubMenuItemTableViewCell.h"
#import "NSDate+Pretty.h"
#import "VCUserStateManager.h"
#import "VCRiderApi.h"
#import "VCUtilities.h"
#import "VCNotifications.h"


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
#define kTriageCell @1013


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
#define kTriageCellInteger 1013


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
            _tableCellList = [NSMutableArray arrayWithArray: @[kUserInfoCell, kMapCell, kDriverSettingsCell, kPaymentCell, kReceiptsCell, kSupportCell, kTriageCell ]];
            
        } else {
            _tableCellList = [NSMutableArray arrayWithArray: @[kUserInfoCell, kMapCell, kPaymentCell, kReceiptsCell, kSupportCell, kTriageCell ]];
        }
        _selectedCellTag = -1;

        [self loadScheduleItems];
        [self countNotificaitons];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    
    // Listen for notifications about updated rides
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleUpdated:) name:kNotificationScheduleUpdated object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self loadScheduleItems];
    [self showOrHideScheduleCell];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) scheduleUpdated:(NSNotification *) notification {
    // just reload the table ?
    [self hideScheduleItems];
    [self loadScheduleItems];
    [self showOrHideScheduleCell];
    [self showScheduleItems];
    [self countNotificaitons];
    [_tableView reloadData];
}

- (void) countNotificaitons {
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"state IN %@ AND confirmed = %@", @[kScheduledState], [NSNumber numberWithBool:NO]];
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
            [menuUserInfoCell.userImageView sd_setImageWithURL:[NSURL URLWithString: [[VCUserStateManager instance] profile].smallImageUrl ]
                                              placeholderImage:[UIImage imageNamed:@"temp-user-profile-icon"]];
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
            Ticket * ticket = [_scheduleItems objectAtIndex:row-scheduleCellIndex-1];
            
            subMenuItemTableViewCell.itemDateLabel.text = [ticket.pickupTime monthAndDay];
            subMenuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            subMenuItemTableViewCell.itemTimeLabel.text = @"";

            if([ticket.state isEqualToString:kScheduledState] && [ticket.confirmed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                subMenuItemTableViewCell.itemTitleLabel.text = [NSString stringWithFormat:@"%@ to %@", ticket.originShortName, ticket.destinationShortName];
                subMenuItemTableViewCell.itemTimeLabel.text = [ticket.pickupTime time];
            } else if ([ticket.state isEqualToString:kScheduledState] && [ticket.confirmed isEqualToNumber:[NSNumber numberWithBool:NO]]) {
                subMenuItemTableViewCell.itemTitleLabel.text = @"Trip Fulfilled!";
                subMenuItemTableViewCell.itemTimeLabel.text = [ticket.pickupTime time];
            } else if ( [@[kCreatedState, kRequestedState] containsObject:ticket.state]) {
                subMenuItemTableViewCell.itemTitleLabel.text = @"Pending Commute";
                subMenuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else if ( [ticket.state isEqualToString:kCommuteSchedulerFailedState]) {
                subMenuItemTableViewCell.itemTitleLabel.text = @"Trip Unfulfilled";
            }
            

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
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-mycar-icon"];
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
            VCDriverSubMenuItemTableViewCell * subMenuItemTableViewCell = [WRUtilities getViewFromNib:@"VCDriverSubMenuItemTableViewCell" class:[VCDriverSubMenuItemTableViewCell class]];
            subMenuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-payments-icon"];
            subMenuItemTableViewCell.itemTitleLabel.text = @"Earnings";
            subMenuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = subMenuItemTableViewCell;
        }
            break;
            
        case kFareReceiptsCellInteger:
        {
            VCDriverSubMenuItemTableViewCell * subMenuItemTableViewCell = [WRUtilities getViewFromNib:@"VCDriverSubMenuItemTableViewCell" class:[VCDriverSubMenuItemTableViewCell class]];
            subMenuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-receipts-icon"];
            subMenuItemTableViewCell.itemTitleLabel.text = @"Fare Receipts";
            subMenuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = subMenuItemTableViewCell;
        }
            break;
        case kTriageCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.menuItemLabel.text = @"Triage";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;
            break;
        }
            
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
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NONE"];
        cell.textLabel.text = @"Error";
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
    else if([cell isKindOfClass:[VCDriverSubMenuItemTableViewCell class]]){
        [(VCDriverSubMenuItemTableViewCell *) cell deselect];
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
            VCTicketViewController * ticketViewController = [[VCTicketViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[ticketViewController]];
            
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
                [self loadScheduleItems];
                [self showScheduleItems];
                
                VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
                [cell select];
            }
        }
            break;
            
        case kScheduleItemCellInteger:
        {
            long scheduleCellIndex = [_tableCellList indexOfObject:kScheduleCell];
            
            
            if(row-scheduleCellIndex-1 < [_scheduleItems count] ) {
                Ticket * ticket = [_scheduleItems objectAtIndex:row-scheduleCellIndex-1];
                VCTicketViewController * ticketViewController = [[VCTicketViewController alloc] init];
                ticketViewController.ticket = ticket;
                [[VCInterfaceManager instance] setCenterViewControllers: @[ticketViewController]];
            } else {
                [WRUtilities criticalErrorWithString:[NSString stringWithFormat: @"Index out of bounds? \n%@", [NSThread callStackSymbols] ]];
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
            
        case kEarningsCellInteger:
        {
            VCEarningsViewController * vc = [[VCEarningsViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[vc]];
            VCDriverSubMenuItemTableViewCell * cell = (VCDriverSubMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
            
        }
            break;
        case kFareReceiptsCellInteger:
        {
            VCFareReceiptsViewController * vc = [[VCFareReceiptsViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[vc]];
            VCDriverSubMenuItemTableViewCell * cell = (VCDriverSubMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
            
            
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
        case kTriageCellInteger:
        {
            [VCDebug showTriage];
         
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
    } else if( [[_tableCellList objectAtIndex:row] integerValue] != kDriverSettingsInteger
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



- (void) showOrHideScheduleCell {
    if([_scheduleItems count] > 0 && [_tableCellList indexOfObject:kScheduleCell] == NSNotFound){
        [_tableCellList insertObject:kScheduleCell atIndex:1];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else if ([_scheduleItems count] == 0 && [_tableCellList indexOfObject:kScheduleCell] != NSNotFound){
        [_tableCellList removeObject:kScheduleCell];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

- (void) loadScheduleItems {
    
    
    //set up filter by date > today at midnight.
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"( ( state = %@ AND confirmed = true ) \
                               OR ( state IN %@  AND direction = 'a' )  \
                               OR ( state = %@ AND direction = 'a' AND confirmed = false ) ) \
                               AND pickupTime > %@ \
                               ",
                               kScheduledState,
                               @[kCreatedState, kRequestedState, kScheduledState],
                               kCommuteSchedulerFailedState,
                               [VCUtilities beginningOfToday]  ];
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
        
        if([_tableCellList containsObject:kScheduleItemCell]){

            /* TODO only remove matching schedule item cells
                Might also consider only allowing these functions within a mutex
            for(int i=0; i<[_tableCellList count]; i++){
                if([_tableCellList objectAtIndex:i] isEqualToString:kScheduleItemCell){
                    
                }
            }
             */
            
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
    
}

@end
