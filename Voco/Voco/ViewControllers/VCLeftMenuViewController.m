//
//  VCLeftMenuViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLeftMenuViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "VCUserStateManager.h"
#import "VCCommuteManager.h"
#import "VCTicketViewController.h"
#import "VCInterfaceManager.h"
#import "VCProfileViewController.h"
#import "VCSupportViewController.h"
#import "VCPaymentsViewController.h"
#import "VCReceiptViewController.h"
#import "VCCarInfoViewController.h"
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
#import "VCReceiptViewController.h"
#import "VCStyle.h"


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
#define kCommuteCell @1014
#define kBackHomeCell @1015
#define kLogoutCell @1016


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
#define kCommuteCellInteger 1014
#define kBackHomeCellInteger 1015
#define kLogoutCellInteger 1016

@interface VCLeftMenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray * tableCellList;
@property (nonatomic, strong) NSArray * scheduleItems;
@property (nonatomic) NSInteger notificationCount;

@property (nonatomic) NSUInteger selectedCellTag;
@end

@implementation VCLeftMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        if([[VCUserStateManager instance] isHovDriver]){
            _tableCellList = [NSMutableArray arrayWithArray: @[kUserInfoCell, kCommuteCell, kBackHomeCell, kMyCarCell, kPaymentCell, kReceiptsCell,  kSupportCell, kLogoutCell, kTriageCell ]];
            
        } else {
            _tableCellList = [NSMutableArray arrayWithArray: @[kUserInfoCell, kCommuteCell, kBackHomeCell, kPaymentCell, kReceiptsCell, kSupportCell, kLogoutCell, kTriageCell ]];
        }
        _selectedCellTag = -1;

        [self loadScheduleItems];

    }
    return self;
}

- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.view.layer insertSublayer:gradient atIndex:0];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self setGradient];
    
    
    // Listen for notifications about updated rides
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleUpdated:) name:kNotificationScheduleUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated:) name:kNotificationTypeProfileUpdated object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self loadScheduleItems];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) profileUpdated:(NSNotification *) notification {
   
    [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) scheduleUpdated:(NSNotification *) notification {
    // just reload the table ?
    [self loadScheduleItems];
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
    
    UIImageView *tempImageView;
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    
    long tag = [[_tableCellList objectAtIndex:row] integerValue];
    switch(tag){
            
        case kUserInfoCellInteger:
        {
            VCMenuUserInfoTableViewCell * menuUserInfoCell = [WRUtilities getViewFromNib:@"VCMenuUserInfoTableViewCell" class:[VCMenuUserInfoTableViewCell class]];
            
            //TODO: This is a placeholder image, replace it with relevant string!
            [menuUserInfoCell.userImageView sd_setImageWithURL:[NSURL URLWithString: [[VCUserStateManager instance] profile].smallImageUrl ]
                                              placeholderImage:[UIImage imageNamed:@"temp-user-profile-icon"]
                                                       options:SDWebImageRefreshCached];
            menuUserInfoCell.userFullName.text = [NSString stringWithFormat: @"%@ %@",
                                                  [[VCUserStateManager instance] profile].firstName,
                                                  [[VCUserStateManager instance] profile].lastName
                                                  ];
            menuUserInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuUserInfoCell;
        }
            break;
            
            
        case kCommuteCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-map-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"My Commute";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;
        }
            break;
            
        case kBackHomeCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = nil;
            menuItemTableViewCell.menuItemLabel.text = @"Back Home";
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
            
            
        case kMyCarCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.iconImageView.image = [UIImage imageNamed: @"menu-mycar-icon"];
            menuItemTableViewCell.menuItemLabel.text = @"Car Info";
            menuItemTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = menuItemTableViewCell;

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
            
        case kLogoutCellInteger:
        {
            VCMenuItemTableViewCell * menuItemTableViewCell = [WRUtilities getViewFromNib:@"VCMenuItemTableViewCell" class:[VCMenuItemTableViewCell class]];
            menuItemTableViewCell.menuItemLabel.text = @"Logout";
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
            
        case kCommuteCellInteger:
        {
            VCTicketViewController * ticketViewController = [[VCTicketViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[ticketViewController]];
            
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
            
            [[VCCommuteManager instance] refreshTickets];
        }
            break;
            
        case kBackHomeCellInteger:
        {
            VCTicketViewController * ticketViewController = [[VCTicketViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[ticketViewController]];
            
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            [cell select];
        }
            break;
            
        case kMyCarCellInteger:
        {
            VCCarInfoViewController * vc = [[VCCarInfoViewController alloc] init];
            [[VCInterfaceManager instance] setCenterViewControllers: @[vc]];
            VCMenuItemTableViewCell * cell = (VCMenuItemTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
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
            VCReceiptViewController * vc = [[VCReceiptViewController alloc] init];
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
            
        case kLogoutCellInteger:
        {
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[VCUserStateManager instance] logoutWithCompletion:^{
                hud.hidden = YES;
            }];
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
    
    _selectedCellTag = tag;
    
    
}





- (void) loadScheduleItems {
    
    
    //set up filter by date > today at midnight.
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"( ( state = %@ AND confirmed = true ) \
                               OR ( state IN %@  AND direction = 'a' )  \
                               AND pickupTime > %@ \
                               )",
                               kScheduledState,
                               @[kCreatedState, kRequestedState, kScheduledState],
                               [VCUtilities beginningOfToday]  ];
    [fetch setPredicate:predicate];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"pickupTime" ascending:YES];
    [fetch setSortDescriptors:@[sort]];
    NSError * error;
    _scheduleItems = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
    
 

}


@end
